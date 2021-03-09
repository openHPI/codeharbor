class RemoveOldTestColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :tests, :feedback_message
    remove_column :tests, :testing_framework_id
    remove_column :tests, :score
  end
end
