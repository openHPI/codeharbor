# frozen_string_literal: true

module ProformaService
  class ConvertZipToTasks < ServiceBase
    def initialize(zip_file:, depth: 0, path: nil)
      @depth = depth + 1
      raise I18n.t('exercises.import_exercise.convert_zip.nested_too_deep') if depth > 5

      @zip_file = zip_file
      @path = path || zip_file.original_filename
    end

    def execute
      if xml_present?
        importer = Proforma::Importer.new(@zip_file)
        task = importer.perform
        tasks = [{path: @path, uuid: task.uuid, task: task}]
      else
        tasks = import_multi
      end

      [tasks].flatten
    end

    private

    def import_multi
      Zip::File.open(@zip_file.path) do |zip_content|
        zip_files = zip_content.filter { |entry| entry.name.match?(/\.zip$/) }
        begin
          zip_files.map! do |entry|
            store_zip_entry_in_tempfile entry
          end
          zip_files.map do |proforma_hash|
            ConvertZipToTasks.call(zip_file: proforma_hash[:file], depth: @depth, path: "#{@path}/#{proforma_hash[:filename]}")
          end
        ensure
          zip_files.each { |hash| hash[:file].unlink }
        end
      end
    end

    def store_zip_entry_in_tempfile(entry)
      tempfile = Tempfile.new(entry.name)
      tempfile.write entry.get_input_stream.read.force_encoding('UTF-8')
      tempfile.rewind
      {file: tempfile, filename: entry.name}
    end

    def xml_present?
      Zip::File.open(@zip_file.path) do |zip_content|
        return zip_content.map(&:name).select { |f| f[/\.xml$/] }.any?
      end
    end
  end
end
