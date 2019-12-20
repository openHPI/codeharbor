class AddPrimaryToDescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :descriptions, :primary, :boolean
  end
end
