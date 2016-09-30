class CreateExerciseAuthors < ActiveRecord::Migration
  def change
    create_table :exercise_authors do |t|
      t.references :exercise, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :exercise_authors, :exercises
    add_foreign_key :exercise_authors, :users
  end
end