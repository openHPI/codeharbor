class ChangeMessageStatus < ActiveRecord::Migration
  def change
    remove_column :messages, :status, :string
    add_column :messages, :sender_status, :string
    add_column :messages, :recipient_status, :string
  end
end
