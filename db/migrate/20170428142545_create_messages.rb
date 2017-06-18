class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text
      t.references :sender
      t.references :recipient
      t.string :status

      t.timestamps null: false
    end
  end
end
