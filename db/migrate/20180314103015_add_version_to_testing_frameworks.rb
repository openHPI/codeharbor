class AddVersionToTestingFrameworks < ActiveRecord::Migration
  def change
    add_column :testing_frameworks, :version, :string
  end
end
