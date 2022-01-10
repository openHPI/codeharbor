# frozen_string_literal: true

require 'nokogiri'
require 'zip'
class Task < ApplicationRecord
  acts_as_taggable_on :state

  groupify :group_member
  validates :title, presence: true

  validates :uuid, uniqueness: true

  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy

  has_many :tests, dependent: :destroy
  has_many :model_solutions, dependent: :destroy

  belongs_to :user
  belongs_to :programming_language, optional: true

  accepts_nested_attributes_for :files, allow_destroy: true
  accepts_nested_attributes_for :tests, allow_destroy: true
  accepts_nested_attributes_for :model_solutions, allow_destroy: true

  scope :not_owner, ->(user) { where.not(user: user) }
  scope :owner, ->(user) { where(user: user) }
  scope :visibility, ->(visibility, user = nil) { {owner: owner(user), public: not_owner(user)}.with_indifferent_access[visibility] }
  scope :created_before_days, ->(days) { where(created_at: days.to_i.days.ago.beginning_of_day..) if days.to_i.positive? }

  serialize :meta_data, HashAsJsonbSerializer

  def self.ransackable_scopes(_auth_object = nil)
    %i[created_before_days]
  end

  def can_access(user)
    self.user == user
  end
end
