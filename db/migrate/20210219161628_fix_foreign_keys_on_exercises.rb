class FixForeignKeysOnExercises < ActiveRecord::Migration[6.0]
  def change
    remove_belongs_to :comments, :exercise
    add_belongs_to :comments, :task, foreign_key: true

    remove_belongs_to :ratings, :exercise
    add_belongs_to :ratings, :task, foreign_key: true

    remove_belongs_to :reports, :exercise
    add_belongs_to :reports, :task, foreign_key: true

    remove_belongs_to :tests, :exercise
    add_foreign_key :tests, :tasks, column: :task_id

    add_foreign_key :model_solutions, :tasks, column: :task_id
  end
end
