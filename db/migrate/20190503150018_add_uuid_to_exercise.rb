class AddUuidToExercise < ActiveRecord::Migration[5.2]
  def change
    add_column :exercises, :uuid, :uuid, null: false, default: 'gen_random_uuid()'
  end
end
