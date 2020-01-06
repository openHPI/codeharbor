class DropAssembliesParts < ActiveRecord::Migration[5.2]
  def change
    drop_table :assemblies_parts
  end
end
