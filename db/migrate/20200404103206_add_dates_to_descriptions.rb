class AddDatesToDescriptions < ActiveRecord::Migration[6.0]
  def up
    add_timestamps :descriptions, null: true
    Description.all.each{|d|d.update(created_at: d.exercise.created_at, updated_at: d.exercise.updated_at)}
    change_column :descriptions, :created_at, :datetime, :null => false, precision: 6
    change_column :descriptions, :updated_at, :datetime, :null => false, precision: 6
  end

  def down
    remove_column :descriptions, :created_at
    remove_column :descriptions, :updated_at
  end
end
