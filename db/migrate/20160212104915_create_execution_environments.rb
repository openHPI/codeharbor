class CreateExecutionEnvironments < ActiveRecord::Migration
  def change
    create_table :execution_environments do |t|
      t.string :language
      t.string :version

      t.timestamps null: false
    end
  end
end
