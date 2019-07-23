class AddSuccessorIdToExercise < ActiveRecord::Migration[5.2]
  def change
    add_reference :exercises, :successor
  end
end
