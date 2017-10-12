class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.references :exercise, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.text :text

      t.timestamps null: false
    end
  end
end
