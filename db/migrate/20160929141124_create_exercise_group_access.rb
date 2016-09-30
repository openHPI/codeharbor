class CreateExerciseGroupAccess < ActiveRecord::Migration
  def change
    create_table :exercise_group_access do |t|
      t.references :exercise, index: true
      t.references :group, index: true

      t.timestamps null: false
    end
    add_foreign_key :exercise_group_access, :exercises
    add_foreign_key :exercise_group_access, :groups
  end
end