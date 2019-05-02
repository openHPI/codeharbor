class AddUuidToExercises < ActiveRecord::Migration[5.2]
  def change
    add_column :exercises, :uuid, :uuid, unique: true
    Exercise.unscoped.all.each { |e| e.update_attribute(:uuid, SecureRandom.uuid) }
    change_column_null :exercises, :uuid, false
  end
end
