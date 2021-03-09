class CreateModelSolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :model_solutions do |t|
      t.string "description"
      t.string "internal_description"
      t.string "xml_id"
      t.references :task

      t.timestamps
    end
  end
end
