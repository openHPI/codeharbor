class RenameCollectionsExercisesToCollectionExercises < ActiveRecord::Migration[5.2]
  def change
    rename_table 'collections_exercises', 'collection_exercises'
  end
end
