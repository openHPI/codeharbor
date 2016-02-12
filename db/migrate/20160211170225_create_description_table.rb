class CreateDescriptionTable < ActiveRecord::Migration
  def change
    create_table :descriptions do |t|
      t.string :text
      t.belongs_to :exercise, index: true, foreign_key: true
    end
  end
end
