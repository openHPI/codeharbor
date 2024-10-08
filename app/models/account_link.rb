# frozen_string_literal: true

class AccountLink < ApplicationRecord
  validates :check_uuid_url, presence: true
  validates :push_url, presence: true
  validates :api_key, presence: true
  validates :name, presence: true
  validates :proforma_version, inclusion: {in: [*ProformaXML::SCHEMA_VERSIONS], allow_nil: true}
  normalizes :proforma_version, with: ->(proforma_version) { proforma_version.presence }

  belongs_to :user

  has_many :account_link_users, dependent: :destroy
  has_many :shared_users, through: :account_link_users, source: :user

  def usable_by?(user)
    self.user == user || user.in?(shared_users)
  end

  def self.parent_resource
    User
  end

  def to_s
    name
  end
end
