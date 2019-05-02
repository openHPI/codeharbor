# frozen_string_literal: true

require 'nokogiri'
require 'zip'

class Exercise < ApplicationRecord
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
  has_many :origin_relations, class_name: 'ExerciseRelation', foreign_key: 'origin_id', dependent: :destroy, inverse_of: :origin
  has_many :clone_relations, class_name: 'ExerciseRelation', foreign_key: 'clone_id', dependent: :destroy, inverse_of: :clone
  validates :descriptions, presence: true

  attr_reader :tag_tokens
  accepts_nested_attributes_for :descriptions, allow_destroy: true
  accepts_nested_attributes_for :exercise_files, allow_destroy: true
  accepts_nested_attributes_for :tests, allow_destroy: true

  default_scope { where(deleted: [nil, false]) }

  scope :timespan, ->(days) { days != 0 ? where('DATE(created_at) >= ?', Time.zone.today - days) : where(nil) }
  scope :text_like, lambda { |text|
    if text.present?
      joins(:descriptions).where('title ILIKE ? OR descriptions.text ILIKE ?', "%#{text.downcase}%", "%#{text.downcase}%")
    else
      where(nil)
    end
  }
  scope :mine, lambda { |user|
    if !user.nil?
      where('user_id = ? OR (exercises.id in (select exercise_id from exercise_authors where user_id = ?))', user.id, user.id)
    else
      where(nil)
    end
  }
  scope :visibility, ->(priv) { !priv.nil? ? where(private: priv) : where(nil) }
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
      if stars != '0'
        where('average_rating >= ?', stars)
      else
        where('average_rating >= ? OR average_rating IS NULL', stars)
      end
    else
      where('average_rating IS NULL')
    end
  end

  # will be replaced with ransack
  # rubocop:disable Metrics/PerceivedComplexity
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
  # rubocop:enable Metrics/PerceivedComplexity

  def can_access(user)
    if private
      if !user.author?(self)
        if !user.access_through_any_group?(self)
          false
        else
          true
        end
      else
        true
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

  def add_attributes(params)
    add_relation(params[:exercise_relation]) if params[:exercise_relation]
    add_license(params)
    add_labels(params[:labels])
    add_groups(params[:groups])
    add_tests(params[:tests_attributes])
    add_files(params[:exercise_files_attributes])
    add_descriptions(params[:descriptions_attributes])
  end

  def add_relation(relation_array)
    relation = ExerciseRelation.find_by(clone: self)
    if !relation
      clone_relations.new(origin_id: relation_array[:origin_id], relation_id: relation_array[:relation_id])
    else
      relation.update(relation_id: relation_array[:relation_id])
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
    description_array.try(:each) do |_key, array|
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
    file_array.try(:each) do |_key, array|
      destroy = array[:_destroy]
      id = array[:id]
      if id
        file = ExerciseFile.find(id)
        if destroy
          file.destroy
        else
          file.update(file_permit(array))
        end
      else
        exercise_files.new(file_permit(array)) unless destroy
      end
    end
  end

  def add_tests(test_array)
    test_array.try(:each) do |_key, array|
      destroy = array[:_destroy]
      id = array[:id]

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
        unless destroy
          file = exercise_files.new(file_permit(array[:exercise_file_attributes]))
          file.purpose = 'test'
          test = Test.new(test_permit(array))
          test.exercise_file = file
          tests << test
        end
      end
    end
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

  def soft_delete
    delete_dependencies
    update(deleted: true)
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
end
