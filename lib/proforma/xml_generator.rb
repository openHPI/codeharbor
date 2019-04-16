# frozen_string_literal: true

require 'nokogiri'

module Proforma
  class XmlGenerator
    def generate_xml(exercise)
      @exercise = exercise
      xml = to_proforma_xml
      xml
    end

    def model_solution_files
      @exercise.exercise_files.where(role: 'Reference Implementation')
    end

    private

    def build_proforma_xml_for_head(xml)
      proforma = xml['p']
      description = @exercise.descriptions.first
      text = if description
               description.text
             else
               ''
             end
      proforma.description do
        proforma.cdata(text)
      end

      proforma.proglang(@exercise.execution_environment.language, 'version' => @exercise.execution_environment.version)
      proforma.send('submission-restrictions') do
        proforma.send('files-restriction') do
          proforma.send('optional', 'filename' => '')
        end
      end
    end

    def build_proforma_xml_for_single_file(xml, file)
      if file.role == 'Main File'
        proforma_file_class = 'template'
        comment = 'main'
      else
        proforma_file_class = 'internal'
        comment = ''
      end
      xml['p'].file(
        'filename' => file.full_file_name,
        'id' => file.id,
        'class' => proforma_file_class,
        'comment' => comment
      ) do
        xml.cdata(file.content)
      end
    end

    def build_proforma_xml_for_exercise_files(xml)
      proforma = xml['p']
      proforma.files do
        @exercise.exercise_files.all? do |file|
          build_proforma_xml_for_single_file(xml, file)
        end
        ### Set Placeholder file for placeholder solution-file and tests if there aren't any
        proforma.file('', 'id' => '0', 'class' => 'internal') if model_solution_files.blank?
      end
    end

    def build_proforma_xml_for_tests(xml)
      proforma = xml['p']
      proforma.tests do
        @exercise.tests.each_with_index do |test, index|
          proforma.test('id' => 't' + index.to_s) do
            proforma.title('')
            proforma.send('test-type', 'unittest')
            proforma.send('test-configuration') do
              proforma.filerefs do
                proforma.fileref('refid' => test.exercise_file.id.to_s)
              end
              testing_framework_split = test.testing_framework.name.split(' ')
              xml['u'].unittest('framework' => testing_framework_split.first, 'version' => testing_framework_split.second)
              xml['c'].send('feedback-message') do
                xml.cdata(test.feedback_message)
              end
            end
          end
        end
      end
    end

    def build_proforma_xml_for_model_solutions(xml)
      proforma = xml['p']
      proforma.send('model-solutions') do
        if model_solution_files.any?
          model_solution_files.each_with_index do |model_solution_file, index|
            proforma = xml['p']
            proforma.send('model-solution', 'id' => 'm' + index.to_s) do
              proforma.filerefs do
                proforma.fileref('refid' => model_solution_file.id.to_s)
              end
            end
          end
        else # #Placeholder solution_file if there aren't any
          proforma.send('model-solution', 'id' => 'm0') do
            proforma.filerefs do
              proforma.fileref('refid' => '0')
            end
          end
        end
      end
    end

    def to_proforma_xml
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        proforma = xml['p']
        description = @exercise.descriptions.first
        language = if description
                     description.language
                   else
                     ''
                   end
        proforma.task('xmlns:p' => 'urn:proforma:task:v1.1', 'lang' => language, 'uuid' => SecureRandom.uuid,
                      'xmlns:u' => 'urn:proforma:tests:unittest:v1.1', 'xmlns:c' => 'codeharbor') do
          build_proforma_xml_for_head(xml)
          build_proforma_xml_for_exercise_files(xml)
          build_proforma_xml_for_model_solutions(xml)
          build_proforma_xml_for_tests(xml)
          # xml['p'].send('grading-hints', 'max-rating' => @exercise.maxrating.to_s)
          proforma.send('meta-data') do
            proforma.title(@exercise.title)
          end
        end
      end
      builder.to_xml
    end
  end
end
