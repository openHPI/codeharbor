# frozen_string_literal: true

require 'nokogiri'
require 'zip'
# rubocop:disable Metrics/ClassLength
class Exercise < ApplicationRecord
  acts_as_taggable_on :state

  groupify :group_member
  validates :title, presence: true
  validates :descriptions, presence: true
  validates :execution_environment, presence: true, unless: :private?
  validates :license, presence: true, unless: :private?
  validate :no_predecessor_loop, :one_primary_description?, :valid_main_file?

  validates :uuid, uniqueness: true

  has_many :exercise_files, dependent: :destroy
  has_many :tests, dependent: :destroy

  has_many :exercise_labels, dependent: :destroy
  has_many :labels, through: :exercise_labels

  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :exercise_authors, dependent: :destroy
  has_many :authors, through: :exercise_authors, source: :user

  has_many :collection_exercises, dependent: :destroy
  has_many :collections, through: :collection_exercises

  has_many :cart_exercises, dependent: :destroy
  has_many :carts, through: :cart_exercises

  belongs_to :predecessor, class_name: 'Exercise', optional: true
  has_one :successor, class_name: 'Exercise', foreign_key: 'predecessor_id', inverse_of: :predecessor, dependent: :nullify

  belongs_to :user
  belongs_to :execution_environment, optional: true
  belongs_to :license, optional: true
  has_many :descriptions, dependent: :destroy
  has_many :origin_relations, class_name: 'ExerciseRelation', foreign_key: 'origin_id', dependent: :destroy, inverse_of: :origin
  has_many :clone_relations, class_name: 'ExerciseRelation', foreign_key: 'clone_id', dependent: :destroy, inverse_of: :clone

  attr_reader :tag_tokens

  accepts_nested_attributes_for :descriptions, allow_destroy: true
  accepts_nested_attributes_for :exercise_files, allow_destroy: true
  accepts_nested_attributes_for :tests, allow_destroy: true

  default_scope { where(deleted: [nil, false]) }

  scope :active, -> { where('NOT EXISTS (SELECT t2.id FROM exercises t2 WHERE exercises.id = t2.predecessor_id)') }
  scope :timespan, ->(days) { days.zero? ? where(nil) : where('DATE(created_at) >= ?', Time.zone.today - days) }
  scope :text_like, lambda { |text|
    if text.present?
      joins(:descriptions).where('title ILIKE ? OR descriptions.text ILIKE ?', "%#{text.downcase}%", "%#{text.downcase}%")
    else
      where(nil)
    end
  }
  scope :mine, lambda { |user|
    if user.nil?
      where(nil)
    else
      where('user_id = ? OR (exercises.id in (select exercise_id from exercise_authors where user_id = ?))', user.id, user.id)
    end
  }
  scope :visibility, ->(priv) { priv.nil? ? where(nil) : where(private: priv) }
  scope :languages, lambda { |languages|
    if languages.present?
      where('(select count(language) from descriptions where exercises.id = descriptions.exercise_id AND '\
        'descriptions.language in (?)) = ? ', languages, languages.length)
    else
      where(nil)
    end
  }
  scope :proglanguage, ->(prog) { prog.present? ? where('execution_environment_id IN (?)', prog) : where(nil) }
  scope :not_deleted, -> { where('(select count(*) from reports where exercises.id = reports.exercise_id) < 3') }
  scope :search_query, lambda { |stars, languages, proglanguages, priv, user, search, intervall|
    joins('LEFT JOIN (SELECT exercise_id, AVG(rating) AS average_rating FROM ratings GROUP BY exercise_id) AS ratings ON '\
    'ratings.exercise_id = exercises.id')
      .mine(user)
      .visibility(priv)
      .rating(stars)
      .languages(languages)
      .proglanguage(proglanguages)
      .text_like(search)
      .timespan(intervall)
      .not_deleted
      .select('exercises.*, coalesce(average_rating, 0) AS average_rating').distinct
  }

  def self.rating(stars)
    if stars.present?
      if stars == '0'
        where('average_rating >= ? OR average_rating IS NULL', stars)
      else
        where('average_rating >= ?', stars)
      end
    else
      where('average_rating IS NULL')
    end
  end

  # will be replaced with ransack
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.search(search, settings, option, user_param)
    case option
    when 'private'
      priv = true
      user = nil
    when 'public'
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
        proglanguages = proglanguages.collect { |x| ExecutionEnvironment.find_by(language: x).id }
      end
    end

    return search_query(stars, languages, proglanguages, priv, user, search, intervall) unless search

    results = search_query(stars, languages, proglanguages, priv, user, search, intervall)
    label = Label.find_by('lower(name) = ?', search.downcase)

    if label
      collection = Label.find_by('lower(name) = ?', search.downcase)
                        .exercises
                        .search_query(stars, languages, proglanguages, priv, user, nil, intervall)

      results.each do |r|
        collection << r unless collection.find_by(id: r.id)
      end
      return collection
    end
    results
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  def can_access(user)
    if private
      if user.author?(self)
        true
      else
        user.access_through_any_group?(self)
      end
    else
      true
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
    (avg_rating * 2).round / 2.0
  end

  def rating_star(avg)
    avg * 2.round / 2
  end

  def in_carts
    carts.count.to_s
  end

  def in_collections
    collections.count.to_s
  end

  def add_attributes(params, user)
    add_relation(params[:exercise_relation]) if params[:exercise_relation]
    add_license(params) if params[:license_id]
    add_labels(params[:labels])
    add_groups(params[:groups], user)
    add_tests(params[:tests_attributes])
    add_files(params[:exercise_files_attributes])
    add_descriptions(params[:descriptions_attributes])
  end

  def soft_delete
    delete_dependencies
    update(deleted: true)
  end

  def duplicate
    Exercise.new(
      private: private,
      descriptions: descriptions.map(&:dup)
    ).tap do |exercise|
      exercise.tests = duplicate_tests
      exercise.exercise_files = duplicate_files_without_testfiles
    end
  end

  def initialize_derivate(user = nil)
    derivate = duplicate
    derivate.assign_attributes attributes.except('id', 'created_at', 'updated_at', 'uuid', 'predecessor_id')

    derivate.clone_relations << ExerciseRelation.new(origin: self, relation: Relation.find_by(name: 'Derivate'))
    derivate.user = user if user
    derivate
  end

  def last_successor
    successor.nil? ? self : successor.last_successor
  end

  def complete_history
    latest_exercise = last_successor
    history = [latest_exercise]
    return history unless latest_exercise.valid?

    history + latest_exercise.all_predecessors
  end

  def all_predecessors
    predecessors = []
    return predecessors unless valid?

    current = predecessor
    until current.nil?
      predecessors << current
      current = current.predecessor
    end
    predecessors
  end

  def save_old_version
    root_exercise = Exercise.unscoped.find(id)
    old_version = root_exercise.duplicate
    old_version.assign_attributes root_exercise.attributes.except('id', 'created_at', 'updated_at', 'uuid')
    ActiveRecord::Base.transaction do
      root_exercise.update!(predecessor: nil)
      old_version.save!
      root_exercise.update!(predecessor: old_version)
    end
  end

  # this needs to be fixed with proper nested forms
  def update_and_version(exercise_params, add_attributes_params, user)
    ActiveRecord::Base.transaction do
      save_old_version
      add_attributes(add_attributes_params, user)
      return true if update(exercise_params)

      raise ActiveRecord::Rollback
    end
    false
  end

  def updatable_by?(user)
    Ability.new(user).can?(:update, self)
  end

  private

  def duplicate_files_without_testfiles
    exercise_files.reject do |file|
      file.exercise.tests.map(&:exercise_file).include? file
    end.map(&:duplicate)
  end

  def duplicate_tests
    tests.map(&:duplicate)
  end

  def no_predecessor_loop
    errors.add(:predecessors, 'are looped') if predecessor_loop?
  end

  def one_primary_description?
    primary_description_count = descriptions.select(&:primary?).count
    errors.add(:exercise, 'has more than one primary descriptions') if primary_description_count > 1
    errors.add(:exercise, 'has no primary description') if primary_description_count < 1
  end

  def valid_main_file?
    errors.add(:files, 'max 1 mainfile') if exercise_files.select { |f| f.role == 'main_file' }.count > 1
  end

  def add_relation(relation_array)
    relation = ExerciseRelation.find_by(clone: self)
    if relation
      relation.update(relation_id: relation_array[:relation_id])
    else
      clone_relations.new(origin_id: relation_array[:origin_id], relation_id: relation_array[:relation_id])
    end
  end

  def add_license(params)
    self.license_id = Exercise.find(params[:exercise_relation][:origin_id]).license_id if params[:exercise_relation]
    self.license_id = params[:license_id] if downloads.zero? && params[:exercise_relation].nil?
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
        labels.new(name: array, color: '006600')
      end
    end
  end

  def add_groups(groups_array, user)
    return unless groups_array

    new_groups = groups_array.drop(1).map do |group_id|
      Group.find(group_id)
    end

    groups_to_add = new_groups - groups
    groups_to_remove = groups - new_groups

    groups_to_add.each do |new_group|
      groups << new_group if new_group.member?(user)
    end

    groups_to_remove.each do |remove_group|
      groups.destroy(remove_group)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def add_descriptions(description_array)
    description_array.try(:each) do |_key, array|
      destroy_param = array[:_destroy]
      id = array[:id]

      if id
        description = descriptions.detect { |desc| desc.id.to_s == id }
        destroy_param ? description.destroy : description.update(text: array[:text], language: array[:language], primary: array[:primary])
      else
        descriptions.new(text: array[:text], language: array[:language], primary: array[:primary]) unless destroy_param
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/PerceivedComplexity
  def add_files(file_array)
    file_array&.each do |_key, params|
      destroy_file = params[:_destroy]
      file_id = params[:id]
      if file_id
        file = ExerciseFile.find(file_id)
        if destroy_file
          file.destroy
        else
          file.update(file_permit(params))
        end
      else
        file = exercise_files.new(file_permit(params)) unless destroy_file
        attachment_from_params(file, params['attachment-base64']) if params['attachment-base64']
      end
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity

  def attachment_from_params(file, attachment)
    file.attachment = attachment
    file.attachment_file_name = file.name + file.file_type.file_extension
  end

  def add_tests(test_array)
    test_array.try(:each) do |_key, array|
      id = array[:id]
      destroy = array[:_destroy]

      if id
        test = Test.find(id)
        if destroy
          test.exercise_file.destroy
          test.destroy
        else
          test.update(test_permit(array))
          test.exercise_file.update(file_permit(array[:exercise_file_attributes]))
        end
      else
        create_new_test array
      end
    end
  end

  def create_new_test(array)
    return if array[:_destroy]

    file = exercise_files.new(file_permit(array[:exercise_file_attributes]))
    file.purpose = 'test'
    test = Test.new(test_permit(array))
    test.exercise_file = file
    tests << test
  end

  def update_file_params(file_attributes)
    if file_attributes[:content].respond_to?(:read)
      file_attributes[:attachment] = file_attributes[:content]
      file_attributes[:content] = nil
    else
      file_attributes[:attachment] = nil
    end
    file_attributes
  end

  def delete_dependencies
    groups.delete_all
    carts.delete_all
    collections.delete_all
    clone_relations.delete_all
  end

  def file_permit(params)
    params = update_file_params(params)
    allowed_params = %i[role content path name hidden read_only file_type_id]
    allowed_params << :attachment if params[:attachment_present] == 'false'
    params.permit(allowed_params)
  end

  def test_permit(params)
    params.permit(:feedback_message, :testing_framework_id)
  end

  def predecessor_loop?
    predecessors = []
    current = predecessor
    until current.nil?
      return true if predecessors.include? current

      predecessors << current
      current = current.predecessor
    end
    false
  end
end
# rubocop:enable Metrics/ClassLength
