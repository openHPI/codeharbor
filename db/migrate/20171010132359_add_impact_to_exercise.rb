class AddImpactToExercise < ActiveRecord::Migration
  def change
    add_reference :exercises, :report, index: true, foreign_key: true
    add_column :exercises, :downloads, :integer, :default => 0
  end
end
