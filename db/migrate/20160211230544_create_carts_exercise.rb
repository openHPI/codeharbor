class CreateCartsExercise < ActiveRecord::Migration
  def change
    create_table :carts_exercises do |t|
      t.belongs_to :exercise, index: true
      t.belongs_to :cart, index: true
    end
  end
end
