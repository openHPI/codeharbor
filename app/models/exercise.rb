require 'nokogiri'

class Exercise < ActiveRecord::Base
  groupify :group_member
  validates :title, presence: true

  has_many :exercise_files, dependent: :destroy
  has_many :tests, dependent: :destroy
  has_and_belongs_to_many :labels
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :exercise_authors, dependent: :destroy
  has_many :authors, through: :exercise_authors, source: :user
  has_and_belongs_to_many :collections, dependent: :destroy
  has_and_belongs_to_many :carts, dependent: :destroy
  belongs_to :user
  belongs_to :execution_environment
  belongs_to :license
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
  scope :mine, -> (user) {(!user.nil?) ? where('user_id = ? OR (id in (select exercise_id from exercise_authors where user_id = ?))', user.id, user.id) : where(nil)}
  scope :visibility, -> (priv) {(!priv.nil?) ? where(private: priv) : where(nil)}
  scope :languages, -> (languages) {(!languages.blank?) ? where('(select count(language) from descriptions where exercises.id = descriptions.exercise_id AND descriptions.language in (?)) = ? ', languages, languages.length) : where(nil)}
  scope :proglanguage, -> (prog) {(!prog.blank?) ? where('execution_environment_id IN (?)', prog) : where(nil)}
  scope :not_deleted, -> {where('(select count(*) from reports where exercises.id = reports.exercise_id) < 3')}
  scope :search_query, -> (stars, languages, proglanguages, priv, user, search, intervall) {joins('LEFT JOIN (SELECT exercise_id, AVG(rating) AS average_rating FROM ratings GROUP BY exercise_id) AS ratings ON ratings.exercise_id = exercises.id').mine(user).visibility(priv).rating(stars).languages(languages).proglanguage(proglanguages).title_like(search).timespan(intervall).not_deleted.select('exercises.*, coalesce(average_rating, 0) AS average_rating')}

  def self.rating(stars)
    if !stars.blank?
      if stars != '0'
        where('average_rating >= ?', stars)
      else
        where('average_rating >= ? OR average_rating IS NULL', stars)
      end
    else
      where('average_rating IS NULL')
    end
  end

  def self.search(search, settings, option, user_param)

    if option == 'private'
      priv = true
      user = nil
    elsif option == 'public'
      priv = false
      user = nil
    else
      priv = nil
      user = user_param
    end
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

    if search
      results = search_query(stars, languages, proglanguages, priv, user, search, intervall)
      label = Label.find_by('lower(name) = ?', search.downcase)

      if label
        collection = Label.find_by('lower(name) = ?', search.downcase).exercises.search_query(stars, languages, proglanguages, priv, user, search, intervall)

        results.each do |r|
          collection << r unless collection.find_by(id: r.id)
        end
        return collection
      end
      return results
    else
      return search_query(stars, languages, proglanguages, priv, user, search, intervall)
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

  def rating_star(avg)
    avg*2.round / 2
  end

  def in_carts
    self.carts.count.to_s
  end

  def in_collections
    self.collections.count.to_s
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
      if label
        labels << label
      else
        labels.new(name: array, color: '006600', label_category: nil)
      end

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
        descriptions.new(text: array[:text], language: array[:language]) unless destroy
      end
    end
  end

  def add_files(file_array)
    file_array.try(:each) do |key, array|
      destroy = array[:_destroy]
      id = array[:id]

      file_type = FileType.find(array[:file_type_id])
      if id
        file = ExerciseFile.find(id)
        destroy ? file.destroy : file.update(file_permit(array))
      else
        exercise_files.new(file_permit(array)) unless destroy
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
          file = ExerciseFile.new(content: array[:content], name: array[:name], path: array[:path], file_type_id: array[:file_type_id], purpose: 'test' )
          test = Test.new(test_permit(array))
          test.exercise_file =  file
          tests << test
        end
      end
    end
  end

  def import_xml(doc)

    self.title = doc.xpath('/p:task/p:meta-data/p:title/text()')

    prog_language = doc.xpath('/p:task/p:proglang/text()').to_s
    version = doc.xpath('/p:task/p:proglang/@version').first.value
    exec_environment = ExecutionEnvironment.where('language = ? AND version = ?', prog_language, version).take
    unless exec_environment
      exec_environment = ExecutionEnvironment.find(1)
    end
    self.execution_environment = exec_environment
    self.private = false
    descriptions.new(text: doc.xpath('/p:task/p:description/text()'), language: doc.xpath('/p:task/@lang').first.value)

    add_files_xml(doc)
    add_tests_xml(doc)
  end

  def add_files_xml(xml)
    xml.xpath('/p:task/p:files/p:file').each do |file|
      role = determine_file_role_from_proforma_file(xml, file)
      unless role === 'Test'
        filename_attribute = file.xpath('@filename').first
        if filename_attribute
          filename = filename_attribute.value
          if filename.include? '/'
            path_name_split = filename.split (/\/(?=[^\/]*$)/)
            path = path_name_split.first
            name_with_type = path_name_split.second
          else
            path = ''
            name_with_type = filename
          end
          if name_with_type.include? '.'
            name_type_split = name_with_type.split('.')
            name = name_type_split.first
            type = name_type_split.second
          else
            name = name_with_type
            type = ''
          end
        else
          path = ''
          name = ''
          type = ''
        end

        file_class = file.xpath('@class').first.value
        content = file.xpath('text()').first

        file = ExerciseFile.new(
            content: content,
            name: name,
            path: path,
            purpose: '',
            file_type: FileType.find_by(file_extension: ".#{type}"),
            role: role,
            hidden: file_class == 'internal',
            read_only: false
        )
        exercise_files << file
      end
    end
  end

  def add_tests_xml(xml)
    xml.xpath('/p:task/p:tests/p:test').each do |test|
      testtype = test.xpath('p:test-type/text()').to_s
      if  testtype == 'unittest'

        framework_name = test.xpath('p:test-configuration/p:unit-test/@framework').first
        if framework_name
          framework = TestingFramework.find_by(name: framework_name)
        else
          framework = TestingFramework.find(1)
        end

        exercise_test = Test.new(testing_framework: framework,
                                    feedback_message: test.xpath('p:test-configuration/c:feedback-message/text()'))

        ref = test.xpath('p:test-configuration/p:filerefs/p:fileref[1]/@refid').first
        if ref
          index = ref.value
          file = xml.xpath('p:task/p:files/p:file[@id="'+index+'"]').first

          filename_attribute = file.xpath('@filename').first
          if filename_attribute
            filename = filename_attribute.value
            if filename.include? '/'
              path_name_split = filename.split (/\/(?=[^\/]*$)/)
              path = path_name_split.first
              name_with_type = path_name_split.second
            else
              path = ''
              name_with_type = filename
            end
            if name_with_type.include? '.'
              name_type_split = name_with_type.split('.')
              name = name_type_split.first
              type = name_type_split.second
            else
              name = name_with_type
              type = ''
            end
          else
            path = ''
            name = ''
            type = ''
          end

          file_class = file.xpath('@class').first.value
          content = file.xpath('text()').first
          file = ExerciseFile.new(content: content,
                                    name: name,
                                    path: path,
                                    purpose: 'test',
                                    file_type: FileType.find_by(file_extension: ".#{type}"),
                                    hidden: file_class == 'internal',
                                    read_only: false
          )
          exercise_test.exercise_file = file
        end

        tests << exercise_test
      end
    end
  end

  def determine_file_role_from_proforma_file(xml, file)
    file_id = file.xpath('@id').first.value
    file_class = file.xpath('@class').first.value
    comment = file.xpath('@comment').first.try(:value)
    is_referenced_by_test = xml.xpath("//p:test/p:test-configuration/p:filerefs/p:fileref[@refid='#{file_id}']")
    is_referenced_by_model_solution = xml.xpath("//p:model-solution/p:filerefs/p:fileref[@refid='#{file_id}']")
    if !is_referenced_by_test.empty? && (file_class == 'internal')
      return I18n.t('models.exercise.role.test')
    elsif !is_referenced_by_model_solution.empty? && (file_class == 'internal')
      return I18n.t('models.exercise.role.reference')
    elsif (file_class == 'template') && (comment == 'main')
      return I18n.t('models.exercise.role.main')
    elsif (file_class == 'internal') && (comment == 'main')
    end
    return I18n.t('models.exercise.role.regular')
  end


  def build_proforma_xml_for_exercise_file(xml, exercise_file)
    if exercise_file.role == 'Main File'
      proforma_file_class = 'template'
      comment = 'main'
    else
      proforma_file_class = 'internal'
      comment = ''
    end

    xml['p'].file(exercise_file.content,
      'filename' => exercise_file.full_file_name,
      'id' => exercise_file.id,
      'class' => proforma_file_class,
      'comment' => comment
    )
  end

  def build_proforma_xml_for_test(xml, test, index)
    proforma = xml['p']
    proforma.test('id' => 't' + index.to_s) {
      proforma.title('')
      proforma.send('test-type', 'unittest')
      proforma.send('test-configuration') {
        proforma.filerefs {
          proforma.fileref('refid' => test.exercise_file.id.to_s)
        }
        xml['u'].unittest('framework' => test.testing_framework.name, 'version' => '')
        xml['c'].send('feedback-message', test.feedback_message)
      }
    }
  end




  def build_proforma_xml_for_model_solution(xml, model_solution_file, index)
    proforma = xml['p']
    proforma.send('model-solution', 'id' => 'm' + index.to_s) {
      proforma.filerefs {
        proforma.fileref('refid' => model_solution_file.id.to_s)
      }
    }
  end

  def to_proforma_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      proforma = xml['p']
      description = descriptions.first
      if description
        language = description.language
        text = description.text
      else
        language = ''
        text = ''
      end
      proforma.task('xmlns:p' => 'urn:proforma:task:v1.1', 'lang' => language, 'uuid' => SecureRandom.uuid,
                    'xmlns:u' => 'urn:proforma:tests:unittest:v1.1', 'xmlns:c' => 'codeharbor'){
        proforma.description(text)
        proforma.proglang(self.execution_environment.language, 'version' => self.execution_environment.version)
        proforma.send('submission-restrictions') {
          proforma.send('files-restriction') {
            proforma.send('optional', 'filename' => '')
          }
        }
        proforma.files {

          self.exercise_files.all? { |file|
            build_proforma_xml_for_exercise_file(xml, file)
          }
          self.tests.all? { |test|
            build_proforma_xml_for_exercise_file(xml, test.exercise_file)
          }

          ### Set Placeholder file for placeholder solution-file and tests if there aren't any
          if self.model_solution_files.blank?
            proforma.file('', 'id' => '0', 'class' => 'internal')
          end
        }

        proforma.send('model-solutions') {

          if self.model_solution_files.any?
            self.model_solution_files.each_with_index { |model_solution_file, index|
              build_proforma_xml_for_model_solution(xml, model_solution_file, index)
            }
          else ##Placeholder solution_file if there aren't any
            proforma.send('model-solution', 'id' => 'm0') {
              proforma.filerefs {
                proforma.fileref('refid' => '0')
              }
            }
          end
        }

        proforma.tests {
          self.tests.each_with_index { |test, index|
            build_proforma_xml_for_test(proforma, test, index)
          }
        }
        #xml['p'].send('grading-hints', 'max-rating' => self.maxrating.to_s)

        proforma.send('meta-data') {
          proforma.title(self.title)
        }
      }
    end
    return builder.to_xml
  end

  def model_solution_files
    self.exercise_files.where(role: 'Reference Implementation')
  end

  def file_permit(params)
    params.permit(:role, :content, :path, :name, :hidden, :read_only, :file_type_id)
  end

  def test_permit(params)
    params.permit(:feedback_message, :testing_framework_id)
  end
end
