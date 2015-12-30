class CreateLabelCategories < ActiveRecord::Migration
  def change
    create_table :label_categories do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
