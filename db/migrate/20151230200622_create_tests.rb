class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.text :content
      t.integer :rating
      t.string :feedback_message
      t.belongs_to :testing_framework, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
