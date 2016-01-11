class AddExerciseRefToTests < ActiveRecord::Migration
  def change
    add_reference :tests, :exercise, index: true, foreign_key: true
  end
end
