class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.string :title
      t.string :description
      t.integer :maxrating
      t.boolean :public

      t.timestamps null: false
    end
  end
end
