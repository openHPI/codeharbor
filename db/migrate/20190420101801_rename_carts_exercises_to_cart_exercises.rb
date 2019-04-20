class RenameCartsExercisesToCartExercises < ActiveRecord::Migration[5.2]
  def change
    rename_table 'carts_exercises', 'cart_exercises'
  end
end
