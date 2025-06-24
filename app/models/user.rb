# frozen_string_literal: true

require 'digest'

class User < ApplicationRecord
  # Include devise modules. Others available are:
  # :timeoutable, :trackable
  devise :database_authenticatable,
    :confirmable,
    :lockable,
    :omniauthable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable

  validates :email, presence: true, uniqueness: {case_sensitive: false}
  validates :first_name, :last_name, :status_group, presence: true
  validates :password_set, inclusion: [true, false]
  validate :validate_openai_api_key, if: -> { openai_api_key.present? }

  has_many :tasks, dependent: :nullify

  has_many :collection_users, dependent: :destroy
  has_many :collections, through: :collection_users

  has_many :collection_user_favorites, dependent: :destroy
  has_many :favorite_collections, through: :collection_user_favorites, source: :collection

  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  has_many :account_link_users, dependent: :destroy
  has_many :shared_account_links, through: :account_link_users, dependent: :destroy, source: :account_link

  has_many :account_links, dependent: :destroy

  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :nullify, inverse_of: :sender
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id', dependent: :nullify, inverse_of: :recipient

  has_many :identities, class_name: 'UserIdentity', dependent: :destroy

  has_one_attached :avatar
  validate :avatar_format, if: -> { avatar.attached? }

  default_scope { where(deleted: [nil, false]) }

  # `Other` is a catch-all for any status that doesn't fit into the other categories and should be *last*.
  enum :status_group, {unknown: 0, learner: 2, educator: 3, other: 1}, default: :unknown, prefix: true
  # When a user is created through the NBP wallet connection, we want to ensure a valid status group.
  # We need to check with a string, because any symbol or integer otherwise used is automatically converted.
  validates :status_group, inclusion: {in: %w[learner educator], message: :unrecognized_role}, on: :create, if: lambda {
    identities.loaded? && identities.any? {|identity| identity.omniauth_provider == 'nbp' }
  }

  # Called by Devise and overwritten for soft-deletion
  def destroy
    return false unless handle_destroy

    self.attributes = {
      first_name: 'deleted',
      last_name: 'user',
      email: Digest::MD5.hexdigest(email),
      deleted: true,
    }

    skip_reconfirmation!
    skip_email_changed_notification!
    save!(validate: false)
  end

  def self.new_from_omniauth(info, omniauth_provider, provider_uid)
    User.new(
      password: Devise.friendly_token[0, 20],
      password_set: false,
      first_name: info[:first_name],
      last_name: info[:last_name],
      email: info[:email],
      status_group: info[:status_group] || :unknown,
      identities: [UserIdentity.new(omniauth_provider:, provider_uid:)]
    )
  end

  def omniauth_identities
    # Only return UserIdentities that can be used for SSO.
    # We create enmeshed UserIdentities to store additional information; they don't have a corresponding omniauth provider.
    identities.where(omniauth_provider: User.omniauth_providers)
  end

  def member_groups
    group_memberships.role_admin.map(&:group)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def handle_destroy # rubocop:disable Naming/PredicateMethod
    handle_group_memberships
    handle_collection_membership
    handle_messages
    handle_user_identities
    true
  end

  def handle_group_memberships
    groups.each do |group|
      next unless group.admin?(self)

      if group.admins.size == 1
        if group.confirmed_members.empty?
          group.destroy
        else
          group.group_memberships.where(role: 'confirmed_member').order(:created_at).first.update(role: 'admin')
          # notify user somehow?
        end
      end
    end
    group_memberships.destroy_all
  end

  def handle_collection_membership
    collections.each do |collection|
      collection.destroy if collection.users.one?
    end
  end

  def handle_messages
    Message.sent_by(self).where.not(action: :plaintext).destroy_all
  end

  def handle_user_identities
    identities.destroy_all
  end

  def unread_messages_count
    Message.where(recipient: self, recipient_status: :unread).count.to_s
  end

  def available_account_links
    account_links + shared_account_links
  end

  def to_page_context
    {
      id:,
    }
  end

  def to_s
    name
  end

  private

  def validate_openai_api_key
    return unless openai_api_key_changed?

    GptService::ValidateApiKey.call(openai_api_key:)
  rescue Gpt::Error::InvalidApiKey
    errors.add(:base, :invalid_api_key)
  end

  def avatar_format
    avatar_blob = avatar.blob
    if avatar_blob.content_type.start_with? 'image/'
      errors.add(:avatar, :size_over_10_mb) if avatar_blob.byte_size > 10.megabytes
    else
      errors.add(:avatar, :not_an_image)
    end
  end
end
