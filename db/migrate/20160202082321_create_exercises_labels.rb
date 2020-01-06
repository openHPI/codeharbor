class CreateExercisesLabels < ActiveRecord::Migration
  def change
    create_table :exercises_labels, id: false do |t|
      t.belongs_to :exercise, index: true
      t.belongs_to :label, index: true
    end
  end
end
