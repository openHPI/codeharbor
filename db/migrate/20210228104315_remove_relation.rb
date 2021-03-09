class RemoveRelation < ActiveRecord::Migration[6.0]
  def change
    drop_table :relations
  end
end
