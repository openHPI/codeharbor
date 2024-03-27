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
  validates :first_name, :last_name, presence: true

  has_many :tasks, dependent: :nullify

  has_many :collection_users, dependent: :destroy
  has_many :collections, through: :collection_users

  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  has_many :account_link_users, dependent: :destroy
  has_many :shared_account_links, through: :account_link_users, dependent: :destroy, source: :account_link

  has_many :reports, dependent: :destroy
  has_many :account_links, dependent: :destroy

  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :nullify, inverse_of: :sender
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id', dependent: :nullify, inverse_of: :recipient

  has_many :identities, class_name: 'UserIdentity', dependent: :destroy

  has_one_attached :avatar
  validate :avatar_format, if: -> { avatar.attached? }

  default_scope { where(deleted: [nil, false]) }

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

  def self.from_omniauth(auth, user = nil) # rubocop:disable Metrics/AbcSize
    identity_params = {omniauth_provider: auth.provider, provider_uid: auth.uid}
    identity = UserIdentity.new(identity_params)

    if user.nil?
      # A new user signs up with an external account
      user = joins(:identities).where(identities: identity_params).first_or_initialize do |new_user|
        # Set these values initially
        new_user.password = Devise.friendly_token[0, 20]
        new_user.identities << identity
        # If you are using confirmable and the provider(s) you use validate emails,
        # uncomment the line below to skip the confirmation emails.
        new_user.skip_confirmation!
      end
    else
      # An existing user connects an external account
      user.identities << identity
    end

    # Update some profile information on every login if present
    user.assign_attributes(auth.info.slice(:email, :first_name, :last_name).to_h.compact)
    if user.changed?
      # We don't want to send a confirmation email for any of the changes
      user.skip_confirmation_notification!
      user.skip_reconfirmation!
      user.save
    end
    user
  end

  def member_groups
    group_memberships.role_admin.map(&:group)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def handle_destroy
    handle_group_memberships
    handle_collection_membership
    handle_messages
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
      collection.destroy if collection.users.count == 1
    end
  end

  def handle_messages
    Message.where(sender: self, param_type: %w[group collection]).destroy_all
  end

  def unread_messages_count
    Message.where(recipient: self, recipient_status: 'u').count.to_s
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

  def avatar_format
    avatar_blob = avatar.blob
    if avatar_blob.content_type.start_with? 'image/'
      errors.add(:avatar, :size_over_10_mb) if avatar_blob.byte_size > 10.megabytes
    else
      errors.add(:avatar, :not_an_image)
    end
  end
end
