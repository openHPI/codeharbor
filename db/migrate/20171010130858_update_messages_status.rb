class UpdateMessagesStatus < ActiveRecord::Migration
  def change
    change_column :messages, :sender_status, :string, :default => 's'
    change_column :messages, :recipient_status, :string, :default => 'u'
  end
end
