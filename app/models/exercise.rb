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
  accepts_nested_attributes_for :exercise_files, allow_destroy: true
  accepts_nested_attributes_for :tests, allow_destroy: true

  scope :timespan, -> (days) {(days != 0) ? where('DATE(created_at) >= ?', Date.today-days) : where(nil)}
  scope :title_like, -> (title) {(!title.blank?) ? where('lower(title) ilike ?',"%#{title.downcase}%") : where(nil)}
  scope :mine, -> (user) {where('user_id = ? OR (id in (select exercise_id from exercise_authors where user_id = ?))', user.id, user.id)}
  scope :languages, -> (languages) {(!languages.blank?) ? where('(select count(language) from descriptions where exercises.id = descriptions.exercise_id AND descriptions.language in (?)) = ? ', languages, languages.length) : where(nil)}
  scope :proglanguage, -> (prog) {(!prog.blank?) ? where('execution_environment_id IN (?)', prog) : where(nil)}

  def self.rating(stars)
    if !stars.blank?
      if stars != '0'
        where('avg_rating >= ?', stars)
      else
        where('avg_rating >= ? OR avg_rating IS NULL', stars)
      end
    else
      where('avg_rating IS NULL')
    end
  end

  def self.search(search, settings, option, user)

    priv = false
    priv = true if option == 'private'
    stars = '0'
    intervall = 0

    if settings
      stars = settings[:stars]
      intervall = settings[:created].to_i
      if settings[:language]
        languages = settings[:language]
        languages.delete_at(0) if languages[0].blank?
      end
      if settings[:proglanguage]
        proglanguages = settings[:proglanguage]
        proglanguages.delete_at(0) if proglanguages[0].blank?
        proglanguages = proglanguages.collect{|x| ExecutionEnvironment.find_by(language: x).id}
      end
    end

    if option == 'private' || option == 'public'
      if search
        results = joins('LEFT JOIN (SELECT exercise_id, AVG(rating) AS avg_rating FROM ratings GROUP BY exercise_id) AS ratings ON ratings.exercise_id = exercises.id').rating(stars).languages(languages).proglanguage(proglanguages).where(private: priv).title_like(search).timespan(intervall)
        label = Label.find_by('lower(name) = ?', search.downcase)

        if label
          collection = Label.find_by('lower(name) = ?', search.downcase).exercises.joins('LEFT JOIN (SELECT exercise_id, AVG(rating) AS avg_rating FROM ratings GROUP BY exercise_id) AS ratings ON ratings.exercise_id = exercises.id').rating(stars).languages(languages).proglanguage(proglanguages).where(private: priv).timespan(intervall)

          results.each do |r|
            collection << r unless collection.find_by(id: r.id)
          end
          return collection
        end
        return results
      else
        return joins('LEFT JOIN (SELECT exercise_id, AVG(rating) AS avg_rating FROM ratings GROUP BY exercise_id) AS ratings ON ratings.exercise_id = exercises.id').rating(stars).languages(languages).proglanguage(proglanguages).where(private: priv).timespan(intervall)
      end
    else
      if search
        results = joins('LEFT JOIN (SELECT exercise_id, AVG(rating) AS avg_rating FROM ratings GROUP BY exercise_id) AS ratings ON ratings.exercise_id = exercises.id').rating(stars).languages(languages).proglanguage(proglanguages).mine(user).title_like(search).timespan(intervall)
        label = Label.find_by('lower(name) = ?', search.downcase)

        if label
          collection = Label.find_by('lower(name) = ?', search.downcase).exercises.joins('LEFT JOIN (SELECT exercise_id, AVG(rating) AS avg_rating FROM ratings GROUP BY exercise_id) AS ratings ON ratings.exercise_id = exercises.id').rating(stars).languages(languages).proglanguage(proglanguages).mine(user).timespan(intervall)

          results.each do |r|
            collection << r unless collection.find_by(id: r.id)
          end
          return collection
        end

        return results
      else
        return joins('LEFT JOIN (SELECT exercise_id, AVG(rating) AS avg_rating FROM ratings GROUP BY exercise_id) AS ratings ON ratings.exercise_id = exercises.id').rating(stars).languages(languages).proglanguage(proglanguages).mine(user).timespan(intervall)
      end
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
      0.0
    else
      result = 1.0 * ratings.average(:rating)
      result.round(1)
    end
  end

  def round_avg_rating
    (avg_rating*2).round / 2.0
  end

  def add_attributes(params)
    if params[:exercise_relation]
      add_relation(params[:exercise_relation])
    end
    add_labels(params[:labels])
    add_groups(params[:groups])
    add_tests(params[:tests_attributes])
    add_files(params[:exercise_files_attributes])
    add_descriptions(params[:descriptions_attributes])
  end

  def add_relation(relation_array)
    relation = ExerciseRelation.find_by(clone: self)
    if !relation
      ExerciseRelation.create(origin_id: relation_array[:origin_id], relation_id: relation_array[:relation_id], clone: self)
    else
      relation.update(origin_id: relation_array[:origin_id], relation_id: relation_array[:relation_id], clone: self)
    end
  end

  def add_labels(labels_array)

    if labels_array
      labels_array.delete_at(0)
      labels.clear
    end

    labels_array.try(:each) do |array|

      label = Label.find_by(name: array)
      unless label
        label = Label.create(name: array, color: '006600', label_category: nil)
      end
      labels << label
    end
  end

  def add_groups(groups_array)

    if groups_array
      groups_array.delete_at(0)
      groups.clear
    end

    groups_array.try(:each) do |array|
      group = Group.find(array)
      groups << group

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
        end
      end
    end
  end

  def build_proforma_xml_for_exercise_file(builder, exercise_file)
    if exercise_file.role == 'Main File'
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
    params.permit(:role, :content, :path, :name, :hidden, :read_only, :file_type_id)
  end

  def test_permit(params)
    params.permit(:feedback_message, :testing_framework_id)
  end
end
