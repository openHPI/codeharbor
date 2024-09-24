# frozen_string_literal: true

class Message < ApplicationRecord
  validates :text, presence: true, unless: -> { %w[group_requested group_accepted group_declined collection].include?(param_type) }
  validates :recipient_id, uniqueness: {scope: %i[param_id param_type], message: :duplicate_share}, if: -> { param_type == 'collection' }
  validate :recipient_not_in_collection, if: -> { recipient_status != 'd' }

  belongs_to :sender, class_name: 'User', inverse_of: :sent_messages
  belongs_to :recipient, class_name: 'User', inverse_of: :received_messages

  scope :received_by, ->(user) { where(recipient: user).where.not(recipient_status: 'd') }
  scope :sent_by, ->(user) { where(sender: user).where.not(sender_status: 'd') }

  after_save :destroy_deleted_message

  def mark_as_deleted(user)
    self.sender_status = 'd' if sender == user
    self.recipient_status = 'd' if recipient == user
  end

  def text # rubocop:disable Metrics/AbcSize
    case param_type
      when 'group_requested'
        I18n.t('groups.send_access_request_message.message', user: sender.name, group: Group.find(param_id).name)
      when 'group_accepted'
        I18n.t('groups.send_grant_access_messages.message', user: sender.name, group: Group.find(param_id).name)
      when 'group_declined'
        I18n.t('groups.send_deny_access_message.message', user: sender.name, group: Group.find(param_id).name)
      when 'collection'
        I18n.t('collections.share_message.text', user: sender.name, collection: Collection.find_by(id: param_id)&.title)
      else
        super
    end
  end

  def self.parent_resource
    User
  end

  private

  def destroy_deleted_message
    destroy if deleted_by_both?
    destroy if deleted_by_one? && param_type == 'collection' # rejected or revoked collection invites should always be deleted
  end

  def deleted_by_sender?
    sender_status == 'd'
  end

  def deleted_by_recipient?
    recipient_status == 'd'
  end

  def deleted_by_both?
    deleted_by_recipient? && deleted_by_sender?
  end

  def deleted_by_one?
    deleted_by_recipient? || deleted_by_sender?
  end

  def recipient_not_in_collection
    if param_type == 'collection' && Collection.find_by(id: param_id)&.users&.include?(recipient)
      errors.add(:recipient_id, :user_already_in_collection)
    end
  end
end
