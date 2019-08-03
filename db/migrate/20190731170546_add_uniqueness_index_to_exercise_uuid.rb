class AddUniquenessIndexToExerciseUuid < ActiveRecord::Migration[5.2]
  def change
    add_index :exercises, :uuid, unique: true
  end
end
