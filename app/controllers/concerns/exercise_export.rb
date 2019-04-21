# frozen_string_literal: true

module ExerciseExport
  def create_exercise_zip(exercise)
    xml_document = generate_xml exercise
    errors = verify_xml xml_document

    unless errors.any?
      @filename = generate_filename exercise.title

      stringio = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry('task.xml')
        zio.write xml_document
        exercise.exercise_files.each do |file|
          add_file(zio, file)
        end
      end
      @binary_data = stringio.string
    end

    {
      data: @binary_data,
      filename: @filename,
      errors: errors
    }
  end

  def push_exercise(exercise, account_link)
    oauth2_client = OAuth2::Client.new(account_link.client_id, account_link.client_secret, site: account_link.push_url)
    oauth2_token = account_link[:oauth2_token]
    token = OAuth2::AccessToken.from_hash(oauth2_client, access_token: oauth2_token)
    xml_generator = Proforma::XmlGenerator.new
    xml_document = xml_generator.generate_xml(exercise)
    begin
      token.post(account_link.push_url, body: xml_document, headers: {'Content-Type' => 'text/xml'})
      return nil
    rescue StandardError => e
      return e
    end
  end

  private

  def add_file(zio, file)
    original_filename = file.attachment.original_filename

    return unless original_filename

    zio.put_next_entry(original_filename)
    zio.write file_attachment_from_paperclip(file.attachment)
  end

  def file_attachment_from_paperclip(file_attachment)
    Paperclip.io_adapters.for(file_attachment).read
  end

  def generate_filename(filename)
    filename.tr('.,:*|"<>/\\', '').gsub(/[ (){}\[\]]/, '_') + '.zip'
  end

  def generate_xml(exercise)
    xml_generator = Proforma::XmlGenerator.new
    xml_generator.generate_xml(exercise)
  end

  def verify_xml(xml_document)
    xsd = Nokogiri::XML::Schema(File.read('app/assets/taskxml.xsd'))
    xsd.validate(Nokogiri::XML(xml_document))
  end
end
