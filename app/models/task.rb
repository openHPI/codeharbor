# frozen_string_literal: true

require 'nokogiri'
require 'zip'
class Task < ApplicationRecord
  include FileConcern
  include ParentValidation
  include TransferValues

  acts_as_taggable_on :state

  before_validation :lowercase_language
  after_commit :sync_metadata_with_nbp, if: -> { Nbp::PushConnector.enabled? }

  validates :title, presence: true

  validates :uuid, uniqueness: true

  validates :language, format: {with: /\A[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*\z/, message: :not_de_or_us}
  validate :primary_language_tag_in_iso639?
  validate :unique_pending_contribution
  validates :parent, presence: true, if: -> { contribution? }
  validate :no_license_change_on_duplicate, on: :update

  has_many :group_tasks, dependent: :destroy
  has_many :groups, through: :group_tasks

  has_many :task_labels, dependent: :destroy
  has_many :labels, through: :task_labels

  has_many :tests, dependent: :destroy, inverse_of: :task
  has_many :model_solutions, dependent: :destroy, inverse_of: :task

  has_many :collection_tasks, dependent: :destroy
  has_many :collections, through: :collection_tasks

  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy

  has_one :task_contribution, dependent: :destroy, inverse_of: :suggestion
  belongs_to :user
  belongs_to :programming_language, optional: true
  belongs_to :license, optional: true
  belongs_to :parent, class_name: 'Task', foreign_key: :parent_uuid, primary_key: :uuid, optional: true, inverse_of: false

  accepts_nested_attributes_for :tests, allow_destroy: true
  accepts_nested_attributes_for :model_solutions, allow_destroy: true
  accepts_nested_attributes_for :group_tasks, allow_destroy: true
  accepts_nested_attributes_for :labels

  scope :owner, ->(user) { where(user:) }
  scope :public_access, -> { where(access_level: :public) }
  scope :group_access, lambda {|user|
    joins(groups: [:users])
      .where(users: {id: user.id})
  }
  scope :visibility, lambda {|visibility, user = nil|
                       {
                         owner: owner(user).not_task_contributions,
                         group: group_access(user).not_task_contributions,
                         public: public_access.not_task_contributions,
                         contribution: pending_contribution(user),
                       }.fetch(visibility, public_access.not_task_contributions)
                     }
  scope :not_task_contributions, lambda {
    where.missing(:task_contribution)
  }
  scope :pending_contribution, ->(user) { joins(:task_contribution).where(user:, access_level: :pending) }
  scope :created_before_days, ->(days) { where(created_at: days.to_i.days.ago.beginning_of_day..) if days.present? }
  scope :min_stars, ->(stars) { with_overall_rating.where('COALESCE(overall_rating, 0) >= ?', stars) }
  scope :with_overall_rating, lambda {
    joins('LEFT JOIN (SELECT task_id, AVG(overall_rating) AS overall_rating FROM ratings GROUP BY task_id)
                             AS ratings ON ratings.task_id = tasks.id').select('tasks.*, overall_rating')
  }
  scope :sort_by_overall_rating_asc, -> { with_overall_rating.order('overall_rating ASC NULLS FIRST') }
  scope :sort_by_overall_rating_desc, -> { with_overall_rating.order('overall_rating DESC NULLS LAST') }
  scope :access_level, ->(access_level) { where(access_level:) }
  scope :fulltext_search, lambda {|input|
    r = left_outer_joins(:programming_language)
    # NOTE: Splitting by spaces like this is not ideal. For example, it breaks for labels containing spaces.
    input.split(/[,\s]+/).each do |keyword|
      r = r.where(["tasks.title ILIKE :keyword
                    OR tasks.description ILIKE :keyword
                    OR tasks.internal_description ILIKE :keyword
                    OR programming_languages.language ILIKE :keyword
                    OR EXISTS (SELECT labels.name FROM task_labels JOIN labels ON task_labels.label_id = labels.id
                                WHERE task_id = tasks.id
                                AND labels.name ILIKE :keyword)",
                   {keyword: "%#{keyword}%"}])
    end
    r
  }
  scope :has_all_labels, lambda {|*input|
    label_names = input.flatten.compact_blank.uniq

    includes(:task_labels).where(task_labels:
                                   TaskLabel.includes(:label)
                                            .where(labels: {name: label_names})
                                            .group(:task_id)
                                            .having('COUNT(DISTINCT name) = ?', label_names.count))
  }

  enum access_level: {private: 0, public: 1}, _default: :private, _prefix: true

  def self.ransackable_scopes(_auth_object = nil)
    %i[created_before_days min_stars access_level fulltext_search has_all_labels]
  end

  def self.ransackable_scopes_skip_sanitize_args
    %i[created_before_days min_stars access_level fulltext_search has_all_labels]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description programming_language_id created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[labels]
  end

  def apply_contribution(contrib)
    transfer_attributes(contrib.suggestion, %w[id parent_uuid access_level user_id uuid created_at], has_files: true)
    transfer_multiple_entities(model_solutions, contrib.suggestion.model_solutions, 'model_solution')
    transfer_multiple_entities(tests, contrib.suggestion.tests, 'test')
    contrib.status = :merged
    save && contrib.save
  end

  def contribution?
    task_contribution.present? && task_contribution.status == 'pending'
  end

  def sync_metadata_with_nbp
    if access_level_public? || saved_change_to_access_level?
      NbpSyncJob.perform_later uuid
      NbpSyncJob.perform_later uuid_previously_was if saved_change_to_uuid? && access_level_previously_was == 'public'
    end
  end

  # This method creates a duplicate while leaving permissions and ownership unchanged
  def duplicate(set_parent_identifiers: true)
    dup.tap do |task|
      if set_parent_identifiers
        task.parent_uuid = task.uuid
      end
      task.uuid = nil
      task.tests = duplicate_tests(set_parent_id: set_parent_identifiers)
      task.files = duplicate_files(set_parent_id: set_parent_identifiers)
      task.model_solutions = duplicate_model_solutions(set_parent_id: set_parent_identifiers)
    end
  end

  # This method resets all permissions and optionally assigns a useful title
  def clean_duplicate(user, change_title: true)
    duplicate.tap do |task|
      task.user = user
      task.groups = []
      task.collections = []
      task.access_level = :private
      if change_title
        task.title = "#{I18n.t('tasks.model.copy_of_task')}: #{task.title}"
      end
    end
  end

  def parent_of?(child)
    child.parent_uuid.nil? ? false : uuid == child.parent_uuid
  end

  def initialize_derivate(user = nil)
    duplicate.tap do |task|
      task.user = user if user
    end
  end

  def average_rating # rubocop:disable Metrics/AbcSize
    return @average_rating if @average_rating

    ratings_arel = Rating.arel_table

    category_averages = Rating::CATEGORIES.map do |category|
      average_rating = ratings_arel[category].average
      coalesced_rating = Arel::Nodes::NamedFunction.new('COALESCE', [average_rating, 0])
      rounded_rating = Arel::Nodes::NamedFunction.new('ROUND', [coalesced_rating, 1])
      rounded_rating.as(category.to_s)
    end

    condition = ratings_arel[:task_id].eq(id)
    query = ratings_arel.project(category_averages).where(condition)
    result = ActiveRecord::Base.connection.exec_query(query.to_sql, 'Averaging ratings').first

    @average_rating = result.symbolize_keys
  end

  def overall_rating
    average_rating[:overall_rating]
  end

  def all_files(cached: true)
    return @all_files if cached && defined?(@all_files)

    @all_files = (files + tests.map(&:files) + model_solutions.map(&:files)).flatten
  end

  def label_names=(label_names)
    self.labels = label_names.uniq.compact_blank.map {|name| Label.find_or_initialize_by(name:) }
    Label.where.not(id: TaskLabel.select(:label_id)).destroy_all
  end

  def label_names
    labels.map(&:name)
  end

  def iso639_lang
    ISO_639.find(language.split('-').first).alpha2
  end

  def to_s
    title
  end

  def contributions(user: nil, status: nil, all_states: false)
    task_filter_set = {parent_uuid: uuid}
    unless user.nil?
      task_filter_set[:user] = user
    end
    query = TaskContribution.joins(:suggestion)
      .where(suggestion: task_filter_set)
    return query if all_states
    return query.where(status:) unless status.nil?

    query.where(status: :pending)
  end

  private

  def duplicate_tests(set_parent_id: true)
    tests.map {|test| test.duplicate(set_parent_id:) }
  end

  def duplicate_files(set_parent_id: true)
    files.map {|file| file.duplicate(set_parent_id:) }
  end

  def duplicate_model_solutions(set_parent_id: true)
    model_solutions.map {|model_solution| model_solution.duplicate(set_parent_id:) }
  end

  def lowercase_language
    language.downcase! if language.present?
  end

  def primary_language_tag_in_iso639?
    if language.present?
      primary_tag = language.split('-').first
      errors.add(:language, :not_iso639) unless ISO_639.find(primary_tag)
    end
  end

  def unique_pending_contribution
    if contribution?
      other_existing_contrib = parent.contributions(user:).where.not(id: task_contribution.id).any?
      errors.add(:task_contribution, :duplicated) if other_existing_contrib
    end
  end

  def no_license_change_on_duplicate
    if parent && license_id_changed? && parent.license != license
      errors.add(:license, :cannot_change_on_duplicate)
    end
  end
end
