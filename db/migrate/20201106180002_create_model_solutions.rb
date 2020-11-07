class CreateModelSolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :model_solutions do |t|
      t.string "description"
      t.string "internal_description"

      t.timestamps
    end
  end
end
