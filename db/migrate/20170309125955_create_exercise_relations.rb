class CreateExerciseRelations < ActiveRecord::Migration
  def change
    create_table :exercise_relations do |t|
      t.references :origin
      t.references :clone
      t.references :relation

      t.timestamps null: false
    end
  end
end
