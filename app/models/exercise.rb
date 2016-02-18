require 'nokogiri'

class Exercise < ActiveRecord::Base
  validates :title, presence: true

  has_many :exercise_files
  has_many :tests
  has_and_belongs_to_many :labels
  has_many :comments
  has_many :ratings
  #has_and_belongs_to_many :collections
  #has_and_belongs_to_many :carts
  belongs_to :user
  belongs_to :execution_environment
  has_many :descriptions
  #validates :descriptions, presence: true

  accepts_nested_attributes_for :descriptions, allow_destroy: true

  def self.search(search)
  	if search
  		results = where('lower(title) LIKE ?', "%#{search.downcase}%")
      label = Label.find_by('lower(name) = ?', search.downcase)

      if label
        collection = Label.find_by('lower(name) = ?', search.downcase).exercises
        results.each do |r|
          collection << r unless collection.find_by(id: r.id)
        end
        return collection
      end
      return results
  	else
      return all
  	end
  end

  def avg_rating
    if ratings.empty?
      return 0
    else
      result = 1.0 * ratings.map(&:rating).inject(:+) / ratings.size
      return result.round(1)
    end
  end

  def round_avg_rating
    (avg_rating*2).round / 2.0
  end

  def add_attributes(params)
    add_tests(params[:tests_attributes])
    add_files(params[:exercise_files_attributes])
    add_descriptions(params[:descriptions_attributes])
  end

  def add_descriptions(description_array)
    description_array.try(:each) do |key, array|
      destroy = array[:_destroy]
      id = array[:id]

      if id
        description = Description.find(id)
        destroy ? description.destroy : description.update(text: array[:text], language: array[:language])
      else
        descriptions << Description.create(text: array[:text], language: array[:language]) unless destroy
      end
    end
  end

  def add_files(file_array)
    file_array.try(:each) do |key, array|
      destroy = array[:_destroy]
      id = array[:id]
      if id
        file = ExerciseFile.find(id)
        destroy ? file.destroy : file.update(file_permit(array))
      else
        exercise_files << ExerciseFile.create(file_permit(array)) unless destroy
      end
    end
  end

  def add_tests(test_array)
    test_array.try(:each) do |key, array|
      destroy = array[:_destroy]
      id = array[:id]
      if id
        test = Test.find(id)
        if destroy
          test.exercise_file.destroy
          test.destroy
        else
          test.update(test_permit(array))
          test.exercise_file.update(content: array[:content])
        end
      else
        unless destroy
          exercise_file = ExerciseFile.create(content: array[:content], purpose: 'test')
          test = Test.create(test_permit(array))
          test.exercise_file = exercise_file
          tests << test
        end
      end
    end
  end

  def build_proforma_xml_for_exercise_file(builder, exercise_file)
    if exercise_file.main
      proforma_file_class = 'template'
      comment = 'main'
    else
      proforma_file_class = 'internal'
      comment = ''
    end

    builder['p'].file(exercise_file.content,
      'filename' => exercise_file.full_file_name,
      'id' => exercise_file.id,
      'class' => proforma_file_class,
      'comment' => comment
    )
  end

  def build_proforma_xml_for_test(builder, test)
    builder['p'].test() {
      builder['p'].send('test-type', 'unittest')
      builder['p'].send('test-configuration') {
        builder['p'].filerefs {
          builder['p'].fileref('refid' => test.exercise_file.id.to_s)
        }
        builder['u'].unittest('framework' => test.testing_framework.name)
        builder['c'].send('feedback-message', test.feedback_message)
      }
    }
  end

  def build_proforma_xml_for_model_solution(builder, model_solution_file)
    builder['p'].send('model-solution') {
      builder['p'].filerefs {
        builder['p'].fileref('refid' => model_solution_file.id.to_s)
      }
    }
  end

  def to_proforma_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.root('xmlns:p' => 'urn:proforma:task:v0.9.4', 'xmlns:u' => 'urn:proforma:tests:unittest:v1', 'xmlns:c' => 'codeharbor') {
        xml['p'].task {
          xml['p'].description(self.descriptions.first.text)
          xml['p'].proglang(self.execution_environment.language, 'version' => self.execution_environment.version)
          xml['p'].send('grading-hints', 'max-rating' => self.maxrating.to_s)
          xml['p'].send('meta-data') {
            xml['p'].title(self.title)
          }
          xml['p'].files {
            self.exercise_files.all? { |file|
              build_proforma_xml_for_exercise_file(xml, file)
            }
          }
          xml['p'].tests {
            self.tests.all? { |test|
              build_proforma_xml_for_test(xml, test)
            }
          }
          xml['p'].send('model-solutions') {
            self.model_solution_files.all? { |model_solution_file|
              build_proforma_xml_for_model_solution(xml, model_solution_file)
            }
          }
        }
      }
    end
    return builder.to_xml
  end

  def model_solution_files
    self.exercise_files.select { |file| file.solution }
  end

  def file_permit(params)
    params.permit(:main, :content, :path, :name, :file_extension)
  end

  def test_permit(params)
    params.permit(:feedback_message, :testing_framework_id)
  end
end
