class RemoveLabelCategory < ActiveRecord::Migration[6.0]
  def change
    remove_reference :labels, :label_category, index: true, foreign_key: true
    drop_table :label_categories
  end
end
