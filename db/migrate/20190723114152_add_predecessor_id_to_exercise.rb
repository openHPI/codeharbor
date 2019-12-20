class AddPredecessorIdToExercise < ActiveRecord::Migration[5.2]
  def change
    add_reference :exercises, :predecessor
  end
end
