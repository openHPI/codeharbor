class AddXmlIdToTaskFile < ActiveRecord::Migration[6.1]
  def change
    add_column :task_files, :xml_id, :string
  end
end
