class AddScoreToTests < ActiveRecord::Migration
  def change
    add_column :tests, :score, :float
  end
end
