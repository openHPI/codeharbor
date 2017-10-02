class AddAvgRatingToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :avg_rating, :float
  end
end
