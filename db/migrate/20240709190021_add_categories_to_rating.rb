# frozen_string_literal: true

class AddCategoriesToRating < ActiveRecord::Migration[7.1]
  def up
    add_column :ratings, :originality, :integer, null: false, default: 1
    add_column :ratings, :description_quality, :integer, null: false, default: 1
    add_column :ratings, :test_quality, :integer, null: false, default: 1
    add_column :ratings, :model_solution_quality, :integer, null: false, default: 1

    ActiveRecord::Base.connection.execute(
      %(UPDATE ratings SET
                originality = rating,
                description_quality = rating,
                test_quality = rating,
                model_solution_quality = rating)
    )

    rename_column :ratings, :rating, :overall_rating
    change_column_default :ratings, :overall_rating, 1
  end

  def down
    change_column_default :ratings, :overall_rating, nil
    rename_column :ratings, :overall_rating, :rating
    remove_column :ratings, :originality
    remove_column :ratings, :description_quality
    remove_column :ratings, :test_quality
    remove_column :ratings, :model_solution_quality
  end
end
