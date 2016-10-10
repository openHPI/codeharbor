class RenameColoumnPublicInExercises < ActiveRecord::Migration
  def change
    rename_column :exercises, :public, :private
  end
end