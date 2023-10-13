# frozen_string_literal: true

module Bridges
  module Oai
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/ClassLength
    class OaiController < ActionController::API
      SUPPORTED_METADATA_PREFIXES = %w[oai_dc lom].freeze
      MAX_RECORDS_PER_RESPONSE = 100
      ERROR_RESPONSE_XSD = 'vendor/assets/schemas/oai-pmh/error_response_combined.xsd'
      SUCCESSFUL_RESPONSE_XSD = 'vendor/assets/schemas/oai-pmh/successful_response_combined.xsd'

      def handle_request
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          parse_parameters!(params)

          verb = @oai_params[:verb]

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
        task = find_record!(@oai_params)
        metadata_prefix = parse_metadata_prefix!(@oai_params[:metadataPrefix])

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
        parse_metadata_prefix!(@oai_params[:metadataPrefix])

        xml.ListIdentifiers do
          records, complete_list_size = find_records!(@oai_params, @resumption_params)

          records.first(MAX_RECORDS_PER_RESPONSE).each do |task|
            export_record_header(xml, task)
          end

          export_resumption_token(xml, records, complete_list_size)
        end
      end

      def handle_list_metadata_formats(xml)
        find_record!(@oai_params) if @oai_params[:identifier].present?

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
        metadata_prefix = parse_metadata_prefix!(@oai_params[:metadataPrefix])

        xml.ListRecords do
          records, complete_list_size = find_records!(@oai_params, @resumption_params)

          records.first(MAX_RECORDS_PER_RESPONSE).each do |task|
            export_record(xml, task, metadata_prefix)
          end

          export_resumption_token(xml, records, complete_list_size)
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
            xml.request bridges_oai_url, @oai_params
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

      def export_resumption_token(xml, records, complete_list_size)
        returned_records = records[...MAX_RECORDS_PER_RESPONSE]
        cursor = @resumption_params.present? ? @resumption_params[:cursor] : 0

        if records.size > MAX_RECORDS_PER_RESPONSE

          new_token = @oai_params.merge(
            {
              last_id: returned_records.last.id,
              ts_from: returned_records.last.updated_at.strftime('%Y-%m-%dT%H:%M:%S.%NZ'),
              ts_until: @resumption_params.present? ? @resumption_params[:ts_until] : Time.zone.now.strftime('%Y-%m-%dT%H:%M:%S.%NZ'),
              cursor: cursor + returned_records.size,
            }
          )

          xml.resumptionToken Base64.encode64(new_token.to_json), cursor:, completeListSize: complete_list_size
        elsif @resumption_params.present?
          xml.resumptionToken '', cursor:, completeListSize: complete_list_size
        end
      end

      def find_record!(params)
        raise OaiError.new('Missing identifier parameter', 'badArgument') unless params[:identifier]

        task = Task.includes(:labels).access_level_public.find_by(uuid: params[:identifier])
        return task if task.present?

        raise OaiError.new('No record found for the specified identifier', 'idDoesNotExist')
      end

      def find_records!(params, resumption_params = nil)
        tasks = Task.includes(:labels).access_level_public.where(updated_at: parse_time_bounds!(params))

        tasks = filter_tasks_by_set(tasks, params[:set]) if params[:set].present?
        complete_list_size = tasks.count

        # ordering required for resumptionTokens; returning one more record to indicate that more are available
        tasks = filter_tasks_by_resumption_params(tasks, resumption_params) if resumption_params.present?
        tasks = tasks.order(:updated_at, :id).limit(MAX_RECORDS_PER_RESPONSE + 1)

        return tasks, complete_list_size if tasks.any? || resumption_params.present?

        raise OaiError.new('No records matched the specified timeframe/identifier/set', 'noRecordsMatch')
      end

      def filter_tasks_by_set(tasks, set_spec)
        raise OaiError.new("The setSpec '#{set_spec}' is invalid", 'badArgument') unless valid_set_spec?(set_spec)

        return tasks if set_spec.casecmp('task').zero?
        return tasks.where(id: TaskLabel.select(:task_id)) if set_spec.casecmp('task:label').zero?

        slices = set_spec.downcase.split(':')
        tasks.where(id: TaskLabel.select(:task_id).where(label_id: slices[2].to_i))
      end

      def filter_tasks_by_resumption_params(tasks, resumption_params)
        tasks.where('updated_at < :ts_until AND (updated_at > :ts_from OR (updated_at = :ts_from AND id > :last_id))', resumption_params)
      end

      def valid_set_spec?(set_spec)
        set_spec.downcase.match?(/^task$|^task:label$|^task:label:[0-9]+$/)
      end

      def parse_parameters!(params)
        if params.key? :resumptionToken
          begin
            params = ActionController::Parameters.new(JSON.parse(Base64.decode64(params[:resumptionToken])))
          rescue JSON::ParserError
            raise OaiError.new('The resumptionToken could not be parsed', 'badResumptionToken')
          end
          parse_resumption_token!(params)
        end

        @oai_params = params.permit(:verb, :identifier, :from, :until, :metadataPrefix, :set).to_h.symbolize_keys
      end

      def parse_resumption_token!(params)
        params.require(%i[last_id ts_from ts_until cursor])

        @resumption_params = {
          last_id: params[:last_id],
          ts_from: Time.zone.strptime(params[:ts_from], '%Y-%m-%dT%H:%M:%S.%NZ'),
          ts_until: Time.zone.strptime(params[:ts_until], '%Y-%m-%dT%H:%M:%S.%NZ'),
          cursor: params[:cursor],
        }
      rescue ArgumentError, ActionController::ParameterMissing
        raise OaiError.new('The resumptionToken could not be parsed', 'badResumptionToken')
      end

      def parse_time!(timestring, round_to: :beginning_of_day)
        time = nil

        if timestring
          begin
            time = Time.iso8601(timestring)
          rescue ArgumentError
            begin
              time = DateTime.strptime(timestring, '%Y-%m-%d').send(round_to)
            rescue Date::Error
              raise OaiError.new("The specified time '#{timestring}' is not in iso8601 nor %Y-%m-%d format", 'badArgument')
            end
          end
        end

        if time.present? && time > Time.zone.now
          Time.zone.now
        else
          time
        end
      end

      def parse_time_bounds!(params)
        from = parse_time!(params[:from])
        to = parse_time!(params[:until], round_to: :end_of_day)
        return from...(to + 1) if to.present? # construct a range spanning until the end of the last second

        from..to
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
