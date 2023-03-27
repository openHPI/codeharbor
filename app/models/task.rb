# frozen_string_literal: true

require 'nokogiri'
require 'zip'
class Task < ApplicationRecord
  acts_as_taggable_on :state

  validates :title, presence: true

  validates :uuid, uniqueness: true
  validates :language, format: {with: /\A[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*\z/, message: I18n.t('tasks.form.errors.language')}

  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy

  has_many :group_tasks, dependent: :destroy
  has_many :groups, through: :group_tasks

  has_many :tests, dependent: :destroy
  has_many :model_solutions, dependent: :destroy

  has_many :collection_tasks, dependent: :destroy
  has_many :collections, through: :collection_tasks

  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy

  belongs_to :user
  belongs_to :programming_language, optional: true

  accepts_nested_attributes_for :files, allow_destroy: true
  accepts_nested_attributes_for :tests, allow_destroy: true
  accepts_nested_attributes_for :model_solutions, allow_destroy: true
  accepts_nested_attributes_for :group_tasks, allow_destroy: true

  scope :not_owner, ->(user) { where.not(user:) }
  scope :owner, ->(user) { where(user:) }
  scope :visibility, ->(visibility, user = nil) { {owner: owner(user), public: not_owner(user)}.with_indifferent_access[visibility] }
  scope :created_before_days, ->(days) { where(created_at: days.to_i.days.ago.beginning_of_day..) if days.to_i.positive? }
  scope :average_rating, lambda {
    select('tasks.*, COALESCE(avg_rating, 0) AS average_rating')
      .joins('LEFT JOIN (SELECT task_id, AVG(rating) AS avg_rating FROM ratings GROUP BY task_id)
                             AS ratings ON ratings.task_id = tasks.id')
  }
  scope :min_stars, ->(stars) { average_rating.where('COALESCE(avg_rating, 0) >= ?', stars) }
  scope :sort_by_average_rating_asc, -> { average_rating.order(average_rating: 'ASC') }
  scope :sort_by_average_rating_desc, -> { average_rating.order(average_rating: 'DESC') }

  serialize :meta_data, HashAsJsonbSerializer

  def self.ransackable_scopes(_auth_object = nil)
    %i[created_before_days min_stars]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description programming_language_id created_at]
  end

  def can_access(user)
    self.user == user
  end

  def duplicate
    dup.tap do |task|
      task.uuid = nil
      task.tests = duplicate_tests
      task.files = duplicate_files
      task.model_solutions = duplicate_model_solutions
    end
  end

  def initialize_derivate(user = nil)
    duplicate.tap do |task|
      task.user = user if user
    end
  end

  def average_rating
    if ratings.empty?
      0
    else
      ratings.sum(&:rating).to_f / ratings.size
    end
  end

  def rating_star
    (average_rating * 2).round / 2.0
  end

  def all_files
    (files + tests.map(&:files) + model_solutions.map(&:files)).flatten
  end

  private

  def duplicate_tests
    tests.map(&:duplicate)
  end

  def duplicate_files
    files.map(&:duplicate)
  end

  def duplicate_model_solutions
    model_solutions.map(&:duplicate)
  end
end
