# frozen_string_literal: true

module TaskFileService
  class AceModeByFilename < ServiceBase
    def initialize(filename:)
      @filename = filename
    end

    def execute
      file_type_by_extension(File.extname(@filename))&.editor_mode || 'ace/mode/java'
    end

    private

    def file_type_by_extension(extension)
      FileType.find_by(file_extension: extension)
    end
  end
end
