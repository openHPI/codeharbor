# frozen_string_literal: true

module Proforma
  class ZipImporter < Importer
    def from_proforma_zip(exercise, doc, files)
      @files = files
      # puts @files.inspect
      from_proforma_xml(exercise, doc)
    end

    def shared_attributes(file, metadata)
      # puts metadata[:filename]
      attachment = @files[metadata[:filename].to_s]
      content = attachment ? nil : file.text
      # puts attachment.inspect
      {
        attachment: attachment,
        attachment_file_name: metadata[:filename],
        content: content,
        name: get_name_from_filename(metadata[:filename]),
        path: get_path_from_filename(metadata[:filename]),
        file_type: get_filetype_from_filename(metadata[:filename]),
        hidden: metadata[:file_class] == 'internal',
        read_only: false
      }
    end
  end
end
