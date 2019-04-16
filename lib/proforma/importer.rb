# frozen_string_literal: true

module Proforma
  class Importer
    def from_proforma_xml(exercise, doc)
      @exercise = exercise
      @exercise.title = doc.xpath('/p:task/p:meta-data/p:title').text
      prog_language = doc.xpath('/p:task/p:proglang').text
      version = doc.xpath('/p:task/p:proglang/@version').first.value
      exec_environment = ExecutionEnvironment.where('language = ? AND version = ?', prog_language, version).take
      exec_environment ||= ExecutionEnvironment.find_by(language: 'Java')
      @exercise.execution_environment = exec_environment
      @exercise.private = false
      @exercise.descriptions.new(text: doc.xpath('/p:task/p:description').text, language: doc.xpath('/p:task/@lang').first.value)
      @exercise.license = License.find_by(name: 'MIT License') # Default License for Test seeds, please change in Production!
      add_files_xml(doc)

      @exercise
    end

    private

    def add_files_xml(xml)
      xml.xpath('/p:task/p:files/p:file').each do |file|
        metadata = file_metadata(file)
        file_attributes = file_attributes(xml, metadata)
        shared_attributes = shared_attributes(file, metadata)
        if metadata[:filename]
          if file_attributes[:role] == 'Test'
            test = add_test_xml(xml, metadata)
            attributes = test_attributes.merge(shared_attributes)
            exercise_file = @exercise.exercise_files.build(attributes)
            test.exercise_file = exercise_file
            @exercise.tests << test
          else
            attributes = file_attributes.merge(shared_attributes)
            exercise_file = @exercise.exercise_files.build(attributes)
            @exercise.exercise_files << exercise_file
          end
        end
      end
    end

    def add_test_xml(xml, metadata)
      test = xml.xpath("//p:test/p:test-configuration/p:filerefs/p:fileref[@refid='#{metadata[:file_id]}']/../../..")
      testtype = test.xpath('p:test-type/text()').to_s
      if  testtype == 'unittest'
        framework_name = test.xpath('p:test-configuration/p:unit-test/@framework').first
        framework_version = test.xpath('p:test-configuration/p:unit-test/@version').first
        framework = if framework_name
                      TestingFramework.find_by(name: framework_name + ' ' + framework_version)
                    else
                      TestingFramework.find_by(name: 'JUnit 4') # Default Testing Framework for Test seeds, please change in Production!
                    end
        exercise_test = Test.new(testing_framework: framework,
                                 feedback_message: test.xpath('p:test-configuration/c:feedback-message').text)
      else
        exercise_test = Test.new
      end
      exercise_test
    end

    def file_metadata(file)
      {
        file_id: file.xpath('@id').first.value,
        file_class: file.xpath('@class').first.value,
        comment: file.xpath('@comment').first.try(:value),
        filename: file.xpath('@filename').first
      }
    end

    def test_attributes
      {
        purpose: 'test'
      }
    end

    def file_attributes(xml, metadata)
      {
        role: determine_file_role_from_proforma_file(xml, metadata),
        purpose: ''
      }
    end

    def shared_attributes(file, metadata)
      {
        content: file.text,
        name: get_name_from_filename(metadata[:filename]),
        path: get_path_from_filename(metadata[:filename]),
        file_type: get_filetype_from_filename(metadata[:filename]),
        hidden: metadata[:file_class] == 'internal',
        read_only: false
      }
    end

    def split_up_filename(filename)
      if filename.include? '/'
        name_with_type = filename.split(%r{/(?=[^/]*$)}).second
        path = filename.split(%r{/(?=[^/]*$)}).first
      else
        name_with_type = filename
        path = ''
      end
      if name_with_type.include? '.'
        name = name_with_type.split('.').first
        type = name_with_type.split('.').second
      else
        name = name_with_type
        type = ''
      end
      [path, name, type]
    end

    def get_filetype_from_filename(filename_attribute)
      if filename_attribute
        type = split_up_filename(filename_attribute.value).third
        filetype = FileType.find_by(file_extension: ".#{type}")
      end
      filetype || FileType.find_by(name: 'Makefile')
    end

    def get_name_from_filename(filename_attribute)
      if filename_attribute
        name = split_up_filename(filename_attribute.value).second
        name
      else
        ''
      end
    end

    def get_path_from_filename(filename_attribute)
      path = split_up_filename(filename_attribute.value).first if filename_attribute
      ''
    end

    def determine_file_role_from_proforma_file(xml, metadata)
      if teacher_defined_test?(xml, metadata)
        I18n.t('models.exercise.role.test')
      elsif reference_implementation?(xml, metadata)
        I18n.t('models.exercise.role.reference')
      elsif main_file?(metadata)
        I18n.t('models.exercise.role.main')
      elsif no_role?(metadata)
        ''
      else
        I18n.t('models.exercise.role.regular')
      end
    end

    def teacher_defined_test?(xml, metadata)
      is_referenced_by_test = xml.xpath("//p:test/p:test-configuration/p:filerefs/p:fileref[@refid='#{metadata[:file_id]}']")
      is_referenced_by_test.any? && (metadata[:file_class] == 'internal')
    end

    def reference_implementation?(xml, metadata)
      is_referenced_by_model_solution = xml.xpath("//p:model-solution/p:filerefs/p:fileref[@refid='#{metadata[:file_id]}']")
      is_referenced_by_model_solution.any? && (metadata[:file_class] == 'internal')
    end

    def main_file?(metadata)
      (metadata[:file_class] == 'template') && (metadata[:comment] == 'main')
    end

    def no_role?(metadata)
      (metadata[:file_class] == 'internal') && (metadata[:comment] == 'main')
    end
  end
end
