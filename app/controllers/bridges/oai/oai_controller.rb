# frozen_string_literal: true

module Bridges
  module Oai
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/ClassLength
    class OaiController < ActionController::API
      SUPPORTED_METADATA_PREFIXES = %w[oai_dc lom].freeze
      ERROR_RESPONSE_XSD = 'vendor/assets/schemas/oai-pmh/error_response_combined.xsd'
      SUCCESSFUL_RESPONSE_XSD = 'vendor/assets/schemas/oai-pmh/successful_response_combined.xsd'

      def handle_request
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          verb = oai_params[:verb]

          raise OaiError.new('Missing verb parameter', 'badVerb') if verb.nil?

          oai_response_template(xml) do
            case verb
              when 'GetRecord'
                handle_get_record(xml)
              when 'Identify'
                handle_identify(xml)
              when 'ListIdentifiers'
                handle_list_identifiers(xml)
              when 'ListMetadataFormats'
                handle_list_metadata_formats(xml)
              when 'ListRecords'
                handle_list_records(xml)
              when 'ListSets'
                handle_list_sets(xml)
              else
                raise OaiError.new('Unknown verb specified', 'badVerb')
            end
          end
        rescue OaiError => e
          return render_oai_error(e)
        end

        render plain: builder.to_xml, content_type: 'text/xml'
      end

      def handle_get_record(xml)
        task = find_record!(oai_params)
        metadata_prefix = parse_metadata_prefix!(oai_params[:metadataPrefix])

        xml.GetRecord do
          export_record(xml, task, metadata_prefix)
        end
      end

      def handle_identify(xml)
        xml.Identify do
          xml.repositoryName 'CodeHarbor'
          xml.baseURL bridges_oai_url
          xml.protocolVersion '2.0'
          xml.adminEmail Settings.oai_pmh.admin_mail
          tasks = Task.access_level_public.order(updated_at: :asc).limit(1)
          xml.earliestDatestamp tasks.present? ? tasks.first.updated_at.iso8601 : Time.utc(1).iso8601
          xml.deletedRecord 'no'
          xml.granularity 'YYYY-MM-DDThh:mm:ssZ'
        end
      end

      def handle_list_identifiers(xml)
        parse_metadata_prefix!(oai_params[:metadataPrefix])

        xml.ListIdentifiers do
          find_records!(oai_params).each do |task|
            export_record_header(xml, task)

            # TODO: resumptionTokens for large answers
          end
        end
      end

      def handle_list_metadata_formats(xml)
        find_record!(oai_params) if params[:identifier].present?

        xml.ListMetadataFormats do
          xml.metadataFormat do
            xml.metadataPrefix 'oai_dc'
            xml.schema 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd'
            xml.metadataNamespace 'http://www.openarchives.org/OAI/2.0/oai_dc/'
          end
          xml.metadataFormat do
            xml.metadataPrefix 'lom'
            xml.schema 'http://ltsc.ieee.org/xsd/lomv1.0/lom.xsd'
            xml.metadataNamespace 'http://ltsc.ieee.org/xsd/LOM'
          end
        end
      end

      def handle_list_records(xml)
        metadata_prefix = parse_metadata_prefix!(oai_params[:metadataPrefix])

        xml.ListRecords do
          find_records!(oai_params).each do |task|
            export_record(xml, task, metadata_prefix)

            # TODO: resumptionTokens for large answers
          end
        end
      end

      def handle_list_sets(xml)
        xml.ListSets do
          xml.set do
            xml.setSpec 'task'
            xml.setName 'Task'
          end
          xml.set do
            xml.setSpec 'task:label'
            xml.setName 'Label'
          end
          Label.find_each do |label|
            xml.set do
              xml.setSpec label_to_set_spec(label)
              xml.setName label.name
            end
          end
        end
      end

      def oai_response_template(xml, include_params: true)
        xml.send(:'OAI-PMH', {
          'xmlns' => 'http://www.openarchives.org/OAI/2.0/',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd',
        }) do
          xml.responseDate Time.now.iso8601
          if include_params
            xml.request bridges_oai_url, oai_params.to_h.symbolize_keys
          else
            xml.request bridges_oai_url
          end

          yield
        end
      end

      def render_oai_error(error)
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          oai_response_template(xml, include_params: %w[badVerb badArgument].exclude?(error.code)) do
            xml.error error.message, code: error.code
          end
        end
        render plain: builder.to_xml, content_type: 'text/xml'
      end

      def export_record_header(xml, task)
        xml.header do
          xml.identifier task.uuid
          xml.datestamp task.updated_at.iso8601
          xml.setSpec 'task'
          task.labels.each do |label|
            xml.setSpec label_to_set_spec(label)
          end
        end
      end

      def export_record(xml, task, format)
        xml.record do
          export_record_header(xml, task)

          xml.metadata do
            if format == :oai_dc
              DublinCoreService::ExportDublinCore.call(task:, xml:)
            elsif format == :lom
              LomService::ExportLom.call(task:, xml:)
            end
          end
        end
      end

      def find_record!(params)
        raise OaiError.new('Missing identifier parameter', 'badArgument') unless params[:identifier]

        task = Task.includes(:labels).access_level_public.find_by(uuid: params[:identifier])
        return task if task.present?

        raise OaiError.new('No record found for the specified identifier', 'idDoesNotExist')
      end

      def find_records!(params)
        tasks = Task.includes(:labels).access_level_public.where(updated_at: parse_time_bounds!(params))

        tasks = filter_tasks_by_set(tasks, params[:set]) if params[:set].present?
        return tasks if tasks.any?

        raise OaiError.new('No records matched the specified timeframe/identifier/set', 'noRecordsMatch')
      end

      def filter_tasks_by_set(tasks, set_spec)
        raise OaiError.new("The setSpec '#{set_spec}' is invalid", 'badArgument') unless valid_set_spec?(set_spec)

        return tasks if set_spec.casecmp('task').zero?
        return tasks.where(id: TaskLabel.select(:task_id)) if set_spec.casecmp('task:label').zero?

        slices = set_spec.downcase.split(':')
        tasks.where(id: TaskLabel.select(:task_id).where(label_id: slices[2].to_i))
      end

      def valid_set_spec?(set_spec)
        set_spec.downcase.match?(/^task$|^task:label$|^task:label:[0-9]+$/)
      end

      def oai_params
        params.permit(:verb, :identifier, :from, :until, :metadataPrefix, :set)
      end

      def parse_time_bounds!(params)
        tfrom = nil
        tuntil = nil

        if params[:from]
          begin
            tfrom = DateTime.iso8601(params[:from])
          rescue Date::Error
            raise OaiError.new("The specified time '#{params[:from]}' is not in iso8601 format", 'badArgument')
          end
        end

        # If the `until` time parameter is in day granularity, we have to round to `end_of_day`, because a timeframe like
        # `from: 2023-01-01, until: 2023-01-01` should span the entire day.
        if params[:until]
          begin
            tuntil = DateTime.strptime(params[:until], '%Y-%m-%d').end_of_day
          rescue Date::Error
            begin
              tuntil = Time.iso8601(params[:until])
            rescue ArgumentError
              raise OaiError.new("The specified time '#{params[:until]}' is not in iso8601 format", 'badArgument')
            end
          end
        end

        tfrom..tuntil
      end

      def parse_metadata_prefix!(prefix)
        raise OaiError.new('Missing metadataPrefix parameter', 'badArgument') if prefix.nil?

        if SUPPORTED_METADATA_PREFIXES.include?(prefix.downcase)
          prefix.downcase.to_sym
        else
          raise OaiError.new("This repository does not support the metadataPrefix '#{prefix}'", 'cannotDisseminateFormat')
        end
      end

      def label_to_set_spec(label)
        "task:label:#{label.id}"
      end
    end
    # rubocop:enable all
  end
end
