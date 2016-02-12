class AddExecutionEnvironmentToExercises < ActiveRecord::Migration
  def change
    add_reference :exercises, :execution_environment, index: true, foreign_key: true
  end
end
