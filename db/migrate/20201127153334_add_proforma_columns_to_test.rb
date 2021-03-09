class AddProformaColumnsToTest < ActiveRecord::Migration[6.0]
  def change
    add_column :tests, :title, :string
    add_column :tests, :description, :string
    add_column :tests, :internal_description, :string
    add_column :tests, :test_type, :string
    add_column :tests, :xml_id, :string
    add_column :tests, :validity, :string
    add_column :tests, :timeout, :string
    add_column :tests, :task_id, :bigint
  end
end
