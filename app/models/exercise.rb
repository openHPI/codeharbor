require 'nokogiri'

class Exercise < ActiveRecord::Base
  groupify :group_member
  validates :title, presence: true

  has_many :exercise_files, dependent: :destroy
  has_many :tests, dependent: :destroy
  has_and_belongs_to_many :labels
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :exercise_authors, dependent: :destroy
  has_many :authors, through: :exercise_authors, source: :user
  has_and_belongs_to_many :collections, dependent: :destroy
  has_and_belongs_to_many :carts, dependent: :destroy
  belongs_to :user
  belongs_to :execution_environment
  has_many :descriptions, dependent: :destroy
  has_many :origin_relations, :class_name => 'ExerciseRelation', :foreign_key => 'origin_id'
  has_many :clone_relations, :class_name => 'ExerciseRelation', :foreign_key => 'clone_id', dependent: :destroy
  #validates :descriptions, presence: true

  attr_reader :tag_tokens
  accepts_nested_attributes_for :descriptions, allow_destroy: true

  def self.search(search, option, user)

    if option == 'private'
      if search
        results = where('lower(title) ilike ? AND private = ?', "%#{search.downcase}%", true)
        label = Label.find_by('lower(name) = ?', search.downcase)

        if label
          collection = Label.find_by('lower(name) = ? AND private = ?', search.downcase, true).exercises
          results.each do |r|
            collection << r unless collection.find_by(id: r.id)
          end
          return collection
        end
        return results
      else
        return where(private: true)
      end

    elsif option == 'public'
      if search
        results = where('lower(title) ILIKE ? AND private = ?', "%#{search.downcase}%", false)
        label = Label.find_by('lower(name) = ?', search.downcase)

        if label
          collection = Label.find_by('lower(name) = ? AND private = ?', search.downcase, false).exercises
          results.each do |r|
            collection << r unless collection.find_by(id: r.id)
          end
          return collection
        end
        return results
      else
        return where(private: false)
      end

    else
      results = where(user:user)
      authors = find(ExerciseAuthor.where(user: user).collect(&:exercise_id))
      authors.each do |author|
        results << author
      end
      return results
    end


  end
  
  def can_access(user)
    if private
      if not user.is_author?(self)
        if not user.has_access_through_any_group?(self)
          return false
        else
          return true
        end
      else
        return true
      end
    else 
      return true
    end
  end


  def avg_rating
    if ratings.empty?
      return 0.0
    else
      result = 1.0 * ratings.map(&:rating).inject(:+) / ratings.size
      return result.round(1)
    end
  end

  def round_avg_rating
    (avg_rating*2).round / 2.0
  end

  def add_attributes(params)
    add_labels(params[:labels])
    add_tests(params[:tests_attributes])
    add_files(params[:exercise_files_attributes])
    add_descriptions(params[:descriptions_attributes])
  end

  def add_labels(labels_array)

    if labels_array
      labels_array.delete_at(0)
    end
    labels_array.try(:each) do |array|
      label = Label.find_by(name: array)
      unless label
        label = Label.create(name: array, color: '006600', label_category: nil)
      end
      labels << label
    end
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

      file_type = FileType.find_by(name: array[:file_type_id])
      unless file_type
        file_type = FileType.create(name: array[:file_type_id])
      end
      array[:file_type_id] = file_type.id

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
          exercise_files << exercise_file
        end
      end
    end
  end

  def build_proforma_xml_for_exercise_file(builder, exercise_file)
    if exercise_file.role == 'Main File'
      proforma_file_class = 'template'
      comment = 'main'
    elsif exercise_file.purpose == 'test'
      proforma_file_class = 'template'
      comment = 'test-file'
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

  def build_proforma_xml_for_test(builder, test, index)
    builder['p'].test('id' => 't' + index.to_s) {
      builder['p'].title('')
      builder['p'].send('test-type', 'unittest')
      builder['p'].send('test-configuration') {
        builder['p'].filerefs {
          builder['p'].fileref('refid' => test.exercise_file.id.to_s)
        }
        builder['u'].unittest('framework' => test.testing_framework.name, 'version' => '')
        builder['c'].send('feedback-message', test.feedback_message)
      }
    }
  end



  def build_proforma_xml_for_model_solution(builder, model_solution_file, index)
    builder['p'].send('model-solution', 'id' => 'm' + index.to_s) {
      builder['p'].filerefs {
        builder['p'].fileref('refid' => model_solution_file.id.to_s)
      }
    }
  end

  def to_proforma_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml['p'].task('xmlns:p' => 'urn:proforma:task:v1.1', 'lang' => descriptions.first.language, 'uuid' => SecureRandom.uuid,
                    'xmlns:u' => 'urn:proforma:tests:unittest:v1.1', 'xmlns:c' => 'codeharbor'){
        xml['p'].description(self.descriptions.first.text)
        xml['p'].proglang(self.execution_environment.language, 'version' => self.execution_environment.version)
        xml['p'].send('submission-restrictions') {
          xml['p'].send('files-restriction') {
            xml['p'].send('optional', 'filename' => '')
          }
        }
        xml['p'].files {

          self.exercise_files.all? { |file|
            build_proforma_xml_for_exercise_file(xml, file)
          }

          ### Set Placeholder file for placeholder solution-file and tests if there aren't any
          if self.model_solution_files.blank? || self.tests.blank?
            xml['p'].file('', 'id' => '0', 'class' => 'template')
          end
        }

        xml['p'].send('model-solutions') {

          if self.model_solution_files.any?
            self.model_solution_files.each_with_index { |model_solution_file, index|
              build_proforma_xml_for_model_solution(xml, model_solution_file, index)
            }
          else ##Placeholder solution_file if there aren't any
            xml['p'].send('model-solution', 'id' => 'm0') {
              xml['p'].filerefs {
                xml['p'].fileref('refid' => '0')
              }
            }
          end
        }

        xml['p'].tests {

          if self.tests.any?
            self.tests.each_with_index { |test, index|
              build_proforma_xml_for_test(xml, test, index)
            }
          else ##Placeholder test if there aren't any
            xml['p'].test('id' => 't0') {
              xml['p'].title('')
              xml['p'].send('test-type', '')
              xml['p'].send('test-configuration')
            }
          end
        }
        #xml['p'].send('grading-hints', 'max-rating' => self.maxrating.to_s)

        xml['p'].send('meta-data') {
          xml['p'].title(self.title)
        }
      }
    end
    return builder.to_xml
  end

  def model_solution_files
    self.exercise_files.select { |file| file.solution }
  end

  def file_permit(params)
    params.permit(:role, :content, :path, :name, :hidden, :read_only, :file_type_id)
  end

  def test_permit(params)
    params.permit(:feedback_message, :testing_framework_id)
  end
end
