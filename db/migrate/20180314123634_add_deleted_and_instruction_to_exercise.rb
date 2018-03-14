class AddDeletedAndInstructionToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :deleted, :boolean
    rename_column :exercises, :description, :instruction
  end
end
