class CreateCollectionsExercise < ActiveRecord::Migration
  def change
    create_table :collections_exercises do |t|
      t.belongs_to :exercise, index: true
      t.belongs_to :collection, index: true
    end
  end
end
