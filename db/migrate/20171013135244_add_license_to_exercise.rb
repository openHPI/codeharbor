class AddLicenseToExercise < ActiveRecord::Migration
  def change
    add_reference :exercises, :license, index: true, foreign_key: true
  end
end
