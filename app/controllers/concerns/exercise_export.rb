module ExerciseExport

  def create_exercise_zip(exercise)
    xsd = Nokogiri::XML::Schema(File.read('app/assets/taskxml.xsd'))
    xml_generator = Proforma::XmlGenerator.new
    xml_document = xml_generator.generate_xml(exercise)
    doc = Nokogiri::XML(xml_document)

    binary_data = nil
    filename = nil
    errors = xsd.validate(doc)

    unless errors.any?
      title = exercise.title
      title = title.tr('.,:*|"<>/\\', '')
      title = title.gsub /[ (){}\[\]]/, '_'
      filename = "#{title}.zip"
      stringio = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry('task.xml')
        zio.write xml_document
        exercise.exercise_files.each do |file|
          if file.attachment.original_filename
            zio.put_next_entry(file.attachment.original_filename)
            zio.write Paperclip.io_adapters.for(file.attachment).read
          end
        end
      end
      binary_data = stringio.string
    end

    {
        data: binary_data,
        filename: filename,
        errors: errors
    }
  end

  def push_exercise(exercise, account_link)
    oauth2_client = OAuth2::Client.new(account_link.client_id, account_link.client_secret, :site => account_link.push_url)
    oauth2_token = account_link[:oauth2_token]
    token = OAuth2::AccessToken.from_hash(oauth2_client, :access_token => oauth2_token)
    xml_generator = Proforma::XmlGenerator.new
    xml_document = xml_generator.generate_xml(exercise)
    begin
      token.post(account_link.push_url, {body: xml_document, headers: {'Content-Type' => 'text/xml'}})
      return nil
    rescue => e
      return e
    end
  end
end