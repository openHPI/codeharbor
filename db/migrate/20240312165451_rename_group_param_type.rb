# frozen_string_literal: true

class RenameGroupParamType < ActiveRecord::Migration[7.1]
  class Message < ApplicationRecord
  end

  def change
    reversible do |dir|
      dir.up do
        Message.where(param_type: :group).find_each {|message| message.update!(param_type: :group_requested) }
      end

      dir.down do
        Message.where(param_type: :group_requested).find_each {|message| message.update!(param_type: :group) }
      end
    end
  end
end
