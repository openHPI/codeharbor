# frozen_string_literal: true

module ProformaService
  class Validation < ServiceBase
    def initialize(task:)
      super()
      @task = task
    end

    # Returns a hash: { <version> => valid?, nil => all_versions_valid? }
    def execute
      result = ProformaXML::SCHEMA_VERSIONS.index_with {|version| version_valid?(version:) }
      result[nil] = result.values.all?
      result
    end

    private

    def version_valid?(version:)
      ProformaService::ExportTask.call(task: @task, options: {version:})
      true
    rescue ProformaXML::PostGenerateValidationError
      false
    end
  end
end
