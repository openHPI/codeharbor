class AddLanguageToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :language, :string
  end
end
