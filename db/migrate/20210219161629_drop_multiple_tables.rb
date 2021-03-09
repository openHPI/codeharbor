class DropMultipleTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :carts
    drop_table :collection_exercises
    drop_table :descriptions
    drop_table :exercise_files
    drop_table :exercise_relations
    drop_table :cart_exercises
    drop_table :exercise_authors
    drop_table :exercises
    drop_table :execution_environments
  end
end
