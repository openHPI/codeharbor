# frozen_string_literal: true

class AddActionEnumToMessages < ActiveRecord::Migration[7.1]
  class Message < ApplicationRecord
    enum :action, {plaintext: 0, collection_shared: 1, group_request: 2, group_approval: 3, group_rejection: 4}, default: :plaintext, prefix: true
  end

  def up
    add_column :messages, :action, :integer, null: false, limit: 1, default: 0, comment: 'Used as enum in Rails'

    actions = {
      collection: :collection_shared,
      group_requested: :group_request,
      group_accepted: :group_approval,
      group_declined: :group_rejection,
    }

    actions.each do |param_type, action|
      Message.where(param_type:).update_all(action: Message.actions[action]) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    remove_column :messages, :action
  end
end
