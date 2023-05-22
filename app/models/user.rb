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

  delegate :can?, :cannot?, to: Ability.new(self)
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

  def self.from_omniauth(auth) # rubocop:disable Metrics/AbcSize
    identity = {omniauth_provider: auth.provider, provider_uid: auth.uid}

    user = joins(:identities).where(identities: identity).first_or_initialize do |new_user|
      # Set these values initially
      new_user.password = Devise.friendly_token[0, 20]
      new_user.identities << UserIdentity.new(identity)
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      new_user.skip_confirmation!
    end

    # Update some profile information on every login
    user.email = auth.info.email
    user.first_name = auth.info.first_name
    user.last_name = auth.info.last_name
    user.save
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

  private

  def avatar_format
    avatar_blob = avatar.blob
    if avatar_blob.content_type.start_with? 'image/'
      errors.add(:avatar, 'size needs to be less than 10MB') if avatar_blob.byte_size > 10.megabytes
    else
      errors.add(:avatar, 'needs to be an image')
    end
  end
end
