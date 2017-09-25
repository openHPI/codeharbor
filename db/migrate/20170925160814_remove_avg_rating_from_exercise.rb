class RemoveAvgRatingFromExercise < ActiveRecord::Migration
  def change
    remove_column :exercises, :avg_rating, :float
  end
end
