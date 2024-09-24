# frozen_string_literal: true

class Message < ApplicationRecord
  validates :text, presence: true, if: -> { action_plaintext? }
  validates :recipient_id,
    uniqueness: {scope: %i[attachment_id attachment_type], message: :duplicate_share},
    if: -> {    action_collection_shared? }
  validate :recipient_not_in_collection, if: -> { !recipient_status_deleted? }

  belongs_to :attachment, polymorphic: true, optional: true

  belongs_to :sender, class_name: 'User', inverse_of: :sent_messages
  belongs_to :recipient, class_name: 'User', inverse_of: :received_messages

  scope :received_by, ->(user) { where(recipient: user).where.not(recipient_status: :deleted) }
  scope :sent_by, ->(user) { where(sender: user).where.not(sender_status: :deleted) }

  after_save :destroy_deleted_message

  enum :action, {plaintext: 0, collection_shared: 1, group_request: 2, group_approval: 3, group_rejection: 4},
    default: :plaintext, prefix: true
  enum :recipient_status, {deleted: 'd', read: 'r', unread: 'u'}, default: :unread, prefix: true
  enum :sender_status, {deleted: 'd', read: 'r', sent: 's'}, default: :sent, prefix: true

  def mark_as_deleted(user)
    self.sender_status = :deleted if sender == user
    self.recipient_status = :deleted if recipient == user
  end

  def text # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # Since this method is used during validations, all referred objects might be blank.
    if action_plaintext?
      super
    elsif action_collection_shared?
      I18n.t('collections.share_message.text', user: sender&.name,
        collection: attachment&.title || I18n.t('activerecord.models.collection.deleted'))
    else
      I18n.t("groups.messages.#{action}", user: sender&.name, group: attachment&.name || I18n.t('activerecord.models.group.deleted'))
    end
  end

  def self.parent_resource
    User
  end

  def reload(options = nil)
    @group = @collection = nil
    super
  end

  private

  def destroy_deleted_message
    destroy if deleted_by_both?
    destroy if deleted_by_one? && action_collection_shared? # rejected or revoked collection invites should always be deleted
  end

  def deleted_by_both?
    recipient_status_deleted? && sender_status_deleted?
  end

  def deleted_by_one?
    recipient_status_deleted? || sender_status_deleted?
  end

  def recipient_not_in_collection
    if action_collection_shared? && attachment&.users&.include?(recipient)
      errors.add(:recipient_id, :user_already_in_collection)
    end
  end
end
