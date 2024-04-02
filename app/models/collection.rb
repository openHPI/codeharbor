# frozen_string_literal: true

class Collection < ApplicationRecord
  MAX_DESCRIPTION_LENGTH = 4000

  validates :title, presence: true
  validates :users, presence: true
  validate :description_is_not_too_long

  has_many :collection_users, dependent: :destroy
  has_many :users, through: :collection_users

  has_many :collection_tasks, lambda {
                                order(rank: :desc).order('collection_tasks.created_at ASC')
                              }, dependent: :destroy, inverse_of: :collection
  has_many :tasks, through: :collection_tasks

  accepts_nested_attributes_for :collection_tasks, allow_destroy: true

  scope :public_access, -> { where(visibility_level: :public) }
  scope :member, lambda {|user|
                   includes(:collection_users).where(collection_users: {user:})
                 }

  enum visibility_level: {private: 0, public: 1}, _default: :private, _prefix: true

  def add_task(task)
    tasks << task unless tasks.find_by(id: task.id)
  end

  def remove_task(task)
    tasks.delete(task)
  end

  def remove_all
    tasks.each do |task|
      tasks.delete(task)
    end
  end

  def to_s
    title
  end

  def description_is_not_too_long
    excess = description.length - MAX_DESCRIPTION_LENGTH
    if excess.positive?
      errors.add(:description, :too_long, excess:, max_length: MAX_DESCRIPTION_LENGTH)
    end
  end
end
