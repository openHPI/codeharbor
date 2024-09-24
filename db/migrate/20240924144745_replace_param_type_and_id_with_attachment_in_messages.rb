# frozen_string_literal: true

class ReplaceParamTypeAndIdWithAttachmentInMessages < ActiveRecord::Migration[7.1]
  GROUP_TYPES = %w[group_requested group_accepted group_declined].freeze

  class Collection < ApplicationRecord
  end

  class Group < ApplicationRecord
  end

  class Message < ApplicationRecord
    belongs_to :attachment, polymorphic: true, optional: true

    enum :action, {plaintext: 0, collection_shared: 1, group_request: 2, group_approval: 3, group_rejection: 4}, default: :plaintext, prefix: true
  end

  def up
    add_reference :messages, :attachment, polymorphic: true, index: true

    execute <<~SQL.squish
      UPDATE messages
      SET attachment_id = param_id
    SQL

    Message.where(param_type: 'collection').update_all(attachment_type: Collection.name) # rubocop:disable Rails/SkipsModelValidations
    Message.where(param_type: GROUP_TYPES).update_all(attachment_type: Group.name) # rubocop:disable Rails/SkipsModelValidations

    Message.includes(:attachment).in_batches do |batch|
      batch.each do |message|
        message.update(attachment_id: nil) if message.attachment.blank? # nullify dangling references
      end
    end

    remove_column :messages, :param_type, :string
    remove_column :messages, :param_id, :integer
  end

  def down
    add_column :messages, :param_type, :string
    add_column :messages, :param_id, :integer

    # restore param_type
    param_types = {
      group_request: 'group_requested',
      group_approval: 'group_accepted',
      group_rejection: 'group_declined',
      collection_shared: 'collection',
    }

    param_types.each do |action, param_type|
      Message.where(action:).update_all(param_type:) # rubocop:disable Rails/SkipsModelValidations
    end

    # restore param_id
    execute <<~SQL.squish
      UPDATE messages
      SET param_id = attachment_id
    SQL

    remove_reference :messages, :attachment, polymorphic: true
  end
end
