class DropExerciseGroupAccesses < ActiveRecord::Migration[6.0]
  def change
    drop_table :exercise_group_accesses
  end
end
