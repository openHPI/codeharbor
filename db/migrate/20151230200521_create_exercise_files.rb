class CreateExerciseFiles < ActiveRecord::Migration
  def change
    create_table :exercise_files do |t|
      t.boolean :main
      t.text :content
      t.string :path
      t.boolean :solution
      t.string :filetype
      t.belongs_to :exercise, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
