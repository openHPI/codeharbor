# frozen_string_literal: true

module Bridges
  module Lom
    class TasksController < ActionController::API
      OML_SCHEMA_PATH = Rails.root.join('vendor/assets/schemas/lom_1484.12.3-2020/lom.xsd')

      def show
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') {|xml| sample_oml(xml) }

        if params[:validate].present?
          schema = Nokogiri::XML::Schema(File.read(OML_SCHEMA_PATH))
          errors = schema.validate(builder.doc)

          return render plain: errors.map(&:message).join("\n") if errors.any?
        end

        render xml: builder
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
          # Other top-level elements: relation, annotation, and classification.
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def oml_general(xml)
        xml.general do
          xml.identifier do
            xml.catalog 'UUID'
            xml.entry task.uuid
          end
          xml.title do
            xml.string task.title, language: task_lang
          end
          xml.language task_lang
          xml.description do
            xml.string task.description, language: task_lang
          end
          if task.programming_language&.language.present?
            xml.keyword do
              xml.string "programming language: #{task.programming_language.language}", language: 'en'
            end
            if task.programming_language&.version.present?
              xml.keyword do
                xml.string "programming language version: #{task.programming_language.version}", language: 'en'
              end
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
      # rubocop:enable all

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
            xml.entity task_author_vcard
            xml.date do
              # TODO: We omit the time part, since the regex provided by the xsd schema seems to be broken regarding
              # the time zone part. Try a validated request, e.g., with '1997-07-16T19:20:30+01:00'. It fails, but
              # it is an example from the IEEE Standard document.
              xml.dateTime task.updated_at.to_date.iso8601
            end
          end
        end
      end

      def oml_meta_metadata(xml)
        xml.metaMetadata do
          xml.metadataSchema 'ProFormA MD 1.0'
        end
      end

      def oml_technical(xml)
        xml.technical do
          xml.format 'text/xml'
          xml.location task_url(id: 'sample')
          xml.location download_task_url(id: 'sample')
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
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
            xml.string task.internal_description, language: task_lang
          end
          xml.language task_lang
        end
      end
      # rubocop:enable all

      def oml_rights(xml)
        xml.rights do
          xml.cost do
            xml.value 'no'
          end
          xml.copyrightAndOtherRestrictions do
            xml.value 'yes'
          end
          xml.description do
            xml.string 'GNU General Public License (GPLv3): https://www.gnu.org/licenses/gpl-3.0.en.html', language: 'en'
          end
        end
      end

      def task
        @task ||= Task.new(
          title: 'Hello World',
          description: 'Write a simple program that prints "Hello World".',
          internal_description: 'This is a simple exercise for your students to begin with Java.',
          uuid: 'f15cb7a3-87eb-4c4c-a998-c33e25d44cdc',
          language: 'English',
          programming_language: pl,
          user:,
          updated_at: Time.zone.now
        )
      end

      def task_lang
        # TODO: Ensure `task.language` returns 2 letter code from ISO 639:1988.
        'en'
      end

      def task_version
        # TODO: Traverse all parent tasks to obtain correct version. This only checks the first parent.
        task.parent_uuid.present? ? 2 : 1
      end

      def task_author_vcard
        <<~VCARD
          BEGIN:VCARD
          FN:#{task.user.first_name} #{task.user.last_name}
          END:VCARD
        VCARD
      end

      def pl
        @pl ||= ProgrammingLanguage.new(language: 'Java', version: '17')
      end

      def user
        @user ||= User.new(
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@openhpi.de'
        )
      end
    end
  end
end
