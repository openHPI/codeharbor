# frozen_string_literal: true

module Bridges
  module Lom
    # rubocop:disable Metrics/ClassLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    class TasksController < ActionController::API
      OML_SCHEMA_PATH = Rails.root.join('vendor/assets/schemas/lom_1484.12.3-2020/lom.xsd')

      def show
        @task = Task.find(params[:id])

        if @task.showable_by?(current_user)
          render xml: Nokogiri::XML::Builder.new(encoding: 'UTF-8') {|xml| sample_oml(xml) }
        else
          render plain: 'Forbidden', status: :forbidden
        end
      end

      private

      def sample_oml(xml)
        xml.lom(xmlns: 'http://ltsc.ieee.org/xsd/LOM') do
          oml_general(xml)
          oml_lifecycle(xml)
          oml_meta_metadata(xml)
          oml_technical(xml)
          oml_educational(xml)
          oml_rights(xml)
          oml_relation(xml)
          oml_annotation(xml)
          # Other top-level elements: classification.
        end
      end

      def oml_general(xml)
        xml.general do
          xml.identifier do
            xml.catalog 'UUID'
            xml.entry @task.uuid
          end
          xml.title do
            xml.string @task.title, language: iso639_lang(@task)
          end
          xml.language iso639_lang(@task)
          xml.description do
            xml.string @task.description, language: iso639_lang(@task)
          end
          if @task.programming_language&.language.present?
            xml.keyword do
              xml.string "programming language: #{@task.programming_language.language}", language: 'en'
            end
            if @task.programming_language&.version.present?
              xml.keyword do
                xml.string "programming language version: #{@task.programming_language.version}", language: 'en'
              end
            end
          end
          if @task.ratings.any?
            xml.keyword do
              xml.string "average rating: #{@task.rating_star}/5.0", language: 'en'
            end
          end
          @task.labels.each do |label|
            xml.keyword do
              xml.string label.name, language: 'en'
            end
          end
          xml.structure do
            xml.value 'atomic'
          end
          xml.aggregationLevel do
            xml.value 1
          end
        end
      end

      def oml_lifecycle(xml)
        xml.lifeCycle do
          xml.version do
            xml.string task_version, language: 'en'
          end
          xml.status do
            xml.value 'final'
          end
          xml.contribute do
            xml.role do
              xml.value 'author'
            end
            xml.entity vcard(@task.user)
            xml.date do
              # We omit the time part, since the regex provided by the xsd schema is broken regarding the time zone part.
              xml.dateTime @task.updated_at.to_date.iso8601
            end
          end
        end
      end

      def oml_meta_metadata(xml)
        xml.metaMetadata do
          xml.identifier do
            xml.catalog 'URI'
            xml.entry request.url
          end
          xml.metadataSchema 'ProFormA MD 1.0'
          xml.language 'en'
        end
      end

      def oml_technical(xml)
        xml.technical do
          xml.format 'text/xml'
          xml.location task_url(@task)
          xml.location download_task_url(@task)
        end
      end

      def oml_educational(xml)
        xml.educational do
          xml.interactivityType do
            xml.value 'active'
          end
          xml.learningResourceType do
            xml.value 'exercise'
          end
          xml.interactivityLevel do
            xml.value 'high'
          end
          xml.semanticDensity do
            xml.value 'high'
          end
          xml.intendedEndUserRole do
            xml.value 'learner'
          end
          xml.context_ do
            xml.value 'school'
          end
          xml.context_ do
            xml.value 'higher education'
          end
          xml.context_ do
            xml.value 'training'
          end
          xml.typicalAgeRange do
            xml.string '13-'
          end
          xml.description do
            xml.string @task.internal_description, language: iso639_lang(@task)
          end
          xml.language iso639_lang(@task)
        end
      end

      def oml_rights(xml)
        xml.rights do
          xml.cost do
            xml.value 'no'
          end
          xml.copyrightAndOtherRestrictions do
            xml.value 'yes'
          end
          if @task.license.present?
            xml.description do
              xml.string @task.license.to_s, language: 'en'
            end
          else
            xml.description do
              xml.string 'Unknown license', language: 'en'
            end
          end
        end
      end

      def oml_relation(xml)
        parent = Task.find_by(uuid: @task.parent_uuid)
        if parent.present?
          xml.relation do
            xml.kind do
              xml.source 'LOMv1.0'
              xml.value 'isversionof'
            end
            xml.resource do
              xml.identifier do
                xml.catalog 'UUID'
                xml.entry parent.uuid
              end
              xml.identifier do
                xml.catalog 'URI'
                xml.entry task_url(parent)
              end
              xml.description do
                xml.string parent.description, language: iso639_lang(parent)
              end
            end
          end
        end
      end

      def oml_annotation(xml)
        @task.comments.each do |comment|
          xml.annotation do
            xml.entity vcard(comment.user)
            xml.date do
              # We omit the time part, since the regex provided by the xsd schema is broken regarding the time zone part.
              xml.dateTime comment.updated_at.to_date.iso8601
            end
            xml.description do
              xml.string comment.text, language: iso639_lang(@task)
            end
          end
        end
      end

      def iso639_lang(task)
        ISO_639.find(task.language.split('-').first).alpha2
      end

      def task_version
        # TODO: Fix this N+1 query for example by adding a version column for tasks
        version = 1
        ancestor = @task
        while ancestor.parent_uuid.present?
          ancestor = Task.find_by(uuid: ancestor.parent_uuid)
          version += 1
        end
        version
      end

      def vcard(user)
        <<~VCARD
          BEGIN:VCARD
          VERSION:3.0
          FN;CHARSET=UTF-8:#{user.name}
          N;CHARSET=UTF-8:#{user.last_name};#{user.first_name};;;
          END:VCARD
        VCARD
      end
    end
    # rubocop:enable all
  end
end
