class CreateExerciseGroupAccesses < ActiveRecord::Migration
  def change
    create_table :exercise_group_accesses do |t|
      t.references :exercise, index: true
      t.references :group, index: true

      t.timestamps null: false
    end
    add_foreign_key :exercise_group_accesses, :exercises
    add_foreign_key :exercise_group_accesses, :groups
  end
end