class CreateTestingFrameworks < ActiveRecord::Migration
  def change
    create_table :testing_frameworks do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
