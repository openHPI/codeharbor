# frozen_string_literal: true

require 'digest'

class User < ApplicationRecord
  groupify :named_group_member
  groupify :group_member

  validates :email, presence: true, uniqueness: {case_sensitive: false}
  validates :username, uniqueness: {allow_blank: true, case_sensitive: false}
  validates :first_name, :last_name, presence: true
  has_secure_password

  has_many :collection_users, dependent: :destroy
  has_many :collections, through: :collection_users

  has_many :account_link_users, dependent: :destroy
  has_many :shared_account_links, through: :account_link_users, dependent: :destroy, source: :account_link

  has_many :reports, dependent: :destroy
  has_many :account_links, dependent: :destroy
  has_many :exercises, dependent: :nullify
  has_one :cart, dependent: :destroy
  has_many :exercise_authors, dependent: :destroy
  has_many :authored_exercises, through: :exercise_authors, source: :exercise
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :nullify, inverse_of: :sender
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id', dependent: :nullify, inverse_of: :recipient

  has_one_attached :avatar
  validate :avatar_format, if: -> { avatar.attached? }

  default_scope { where(deleted: [nil, false]) }

  before_create :confirmation_token
  # before_destroy :handle_destroy, prepend: true

  def soft_delete
    return false unless handle_destroy

    email = self.email
    new_email = Digest::MD5.hexdigest email
    update(first_name: 'deleted', last_name: 'user', email: new_email, deleted: true, username: nil)
  end

  def member_groups
    groups - groups.as(:pending)
  end

  def cart_count
    if cart
      cart.exercises.size
    else
      0
    end
  end

  def author?(exercise)
    exercise_authors = User.find(ExerciseAuthor.where(exercise_id: exercise.id).collect(&:user_id))
    exercise_authors.include? self
  end

  def name
    "#{first_name} #{last_name}"
  end

  def handle_destroy
    destroy = handle_group_memberships
    if !destroy
      false
    else
      handle_collection_membership
      handle_exercises
      handle_messages
      true
    end
  end

  def access_through_any_group?(exercise)
    shares_any_group?(exercise)
  end

  def handle_group_memberships
    # in_all_groups?(as: 'admin')

    groups.each do |group|
      if group.users.size > 1
        return false if in_group?(group, as: 'admin') && group.admins.size == 1
      else
        group.destroy
      end
    end
    true
  end

  def handle_collection_membership
    collections.each do |collection|
      collection.delete if collection.users.count == 1
    end
  end

  def handle_exercises
    Exercise.where(user: self).find_each { |e| e.update(user: nil) }
  end

  def handle_messages
    Message.where(sender: self, param_type: %w[exercise group collection]).destroy_all
  end

  def unread_messages_count
    Message.where(recipient: self, recipient_status: 'u').count.to_s
  end

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(validate: false)
  end

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now.utc
    save!
  end

  def password_token_valid?
    (reset_password_sent_at + 4.hours) > Time.now.utc
  end

  def reset_password!(password, password_confirmation)
    self.reset_password_token = nil
    self.password = password
    self.password_confirmation = password_confirmation
    save
  end

  def available_account_links
    account_links + shared_account_links
  end

  private

  def confirmation_token
    self.confirm_token = SecureRandom.urlsafe_base64.to_s if confirm_token.blank?
  end

  def avatar_format
    avatar_blob = avatar.blob
    if avatar_blob.content_type.start_with? 'image/'
      errors.add(:avatar, 'size needs to be less than 10MB') if avatar_blob.byte_size > 10.megabytes
    else
      errors.add(:avatar, 'needs to be an image')
    end
  end
end
