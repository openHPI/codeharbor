class AddColumnsToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :param_type, :string
    add_column :messages, :param_id, :integer
  end
end
