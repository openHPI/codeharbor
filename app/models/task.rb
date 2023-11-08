# frozen_string_literal: true

require 'nokogiri'
require 'zip'
class Task < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include TransferValues
  include ParentValidation

  acts_as_taggable_on :state
  attribute :parent_id
  validates :title, presence: true

  validates :uuid, uniqueness: true

  before_validation :lowercase_language
  validates :language, format: {with: /\A[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*\z/, message: :not_de_or_us}
  validate :primary_language_tag_in_iso639?
  validate :unique_pending_contribution

  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy

  has_many :group_tasks, dependent: :destroy
  has_many :groups, through: :group_tasks

  has_many :task_labels, dependent: :destroy
  has_many :labels, through: :task_labels

  has_many :tests, dependent: :destroy
  has_many :model_solutions, dependent: :destroy

  has_many :collection_tasks, dependent: :destroy
  has_many :collections, through: :collection_tasks

  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy

  # TODO: Do we want to have a has_one AND a has_many association for contributions?
  has_one :task_contribution, dependent: :destroy, inverse_of: :modifying_task
  belongs_to :user
  belongs_to :programming_language, optional: true
  belongs_to :license, optional: true

  accepts_nested_attributes_for :files, allow_destroy: true
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
                         owner: owner(user),
                         group: group_access(user),
                         public: public_access,
                       }.fetch(visibility, public_access)
                     }
  scope :created_before_days, ->(days) { where(created_at: days.to_i.days.ago.beginning_of_day..) if days.to_i.positive? }
  scope :average_rating, lambda {
    select('tasks.*, COALESCE(avg_rating, 0) AS average_rating')
      .joins('LEFT JOIN (SELECT task_id, AVG(rating) AS avg_rating FROM ratings GROUP BY task_id)
                             AS ratings ON ratings.task_id = tasks.id')
  }
  scope :min_stars, ->(stars) { average_rating.where('COALESCE(avg_rating, 0) >= ?', stars) }
  scope :sort_by_average_rating_asc, -> { average_rating.order(average_rating: 'ASC') }
  scope :sort_by_average_rating_desc, -> { average_rating.order(average_rating: 'DESC') }
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

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description programming_language_id created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[labels]
  end

  def can_access(user)
    showable_by?(user) && updateable_by?(user) && destroyable_by?(user)
  end

  def author?(user)
    self.user == user
  end

  def showable_by?(user)
    user.nil? ? false : Pundit.policy(user, self).show?
  end

  def updateable_by?(user)
    user.nil? ? false : Pundit.policy(user, self).update?
  end

  def destroyable_by?(user)
    user.nil? ? false : Pundit.policy(user, self).destroy?
  end

  def lom_showable_by?(user)
    access_level_public? || showable_by?(user)
  end

  def contribution?
    task_contribution.present? && task_contribution.status == 'pending'
  end

  # rubocop:disable Metrics/AbcSize
  def apply_contribution(contrib)
    contrib_attributes = contrib.modifying_task.attributes.except!('parent_uuid', 'access_level', 'user_id', 'uuid', 'id')
    assign_attributes(contrib_attributes)
    transfer_linked_files(contrib.modifying_task)
    self.model_solutions = transfer_multiple(model_solutions, contrib.modifying_task.model_solutions, {task_id: id})
    self.tests = transfer_multiple(tests, contrib.modifying_task.tests, {task_id: id})
    contrib.status = :merged
    save && contrib.save
  end
  # rubocop:enable Metrics/AbcSize

  # TODO: Find a better name for the methods
  def in_same_group?(user)
    in_same_group_member?(user) || in_same_group_admin?(user)
  end

  def in_same_group_member?(user)
    groups.any? {|group| group.confirmed_member?(user) }
  end

  def in_same_group_admin?(user)
    groups.any? {|group| group.admin?(user) }
  end

  # This method creates a duplicate while leaving permissions and ownership unchanged
  def duplicate
    dup.tap do |task|
      task.parent_uuid = task.uuid
      task.uuid = nil
      task.tests = duplicate_tests
      task.files = duplicate_files
      task.model_solutions = duplicate_model_solutions
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

  def parent
    parent_uuid.nil? ? nil : Task.find_by(uuid: parent_uuid).presence
  end

  def parent_of?(child)
    child.parent_uuid.nil? ? false : uuid == child.parent_uuid
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

  def contributions
    Task.joins(:task_contribution)
      .where(parent_uuid: uuid, task_contribution: {status: :pending})
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
      other_existing_contrib = parent&.contributions&.where(user:)&.any?
      errors.add(:task_contribution, :duplicated) if other_existing_contrib
    end
  end
end
