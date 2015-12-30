class AddUserAndEnvironmentToExercise < ActiveRecord::Migration
  def change
  	add_foreign_key :exercises, :users
  	add_foreign_key :exercises, :environments
  end
end
