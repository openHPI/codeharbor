class CreateExercisesLabels < ActiveRecord::Migration[4.2]
  def change
    create_table :exercises_labels do |t|
      t.belongs_to :exercise, index: true
      t.belongs_to :label, index: true
    end
  end
end
