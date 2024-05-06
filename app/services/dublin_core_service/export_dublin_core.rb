# frozen_string_literal: true

module DublinCoreService
  class ExportDublinCore < ServiceBase
    def initialize(task:, xml:)
      super()
      @task = task
      @xml = xml
    end

    def execute # rubocop:disable Metrics/AbcSize
      @xml.send(:'oai_dc:dc', {
        'xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
                        'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
                        'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
      }) do
        @xml['dc'].identifier @task.uuid
        @xml['dc'].type 'InteractiveResource'
        @xml['dc'].title @task.title
        @xml['dc'].creator @task.user.name
        @xml['dc'].description @task.description

        keywords = @task.labels.map(&:name)
        keywords.append(@task.programming_language.language_with_version) if @task.programming_language.present?
        @xml['dc'].subject keywords.join(', ') if keywords.present?

        @xml['dc'].language @task.iso639_lang
        @xml['dc'].date @task.updated_at.iso8601
        @xml['dc'].rights @task.license.to_s if @task.license.present?
      end
    end
  end
end
