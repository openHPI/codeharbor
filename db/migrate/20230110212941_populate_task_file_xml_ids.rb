class PopulateTaskFileXmlIds < ActiveRecord::Migration[6.1]
  def up
    Task.all.each do |task|
      task.all_files.each_with_index do |file, index|
        file.update_attribute(:xml_id, index)
      end
    end
  end
end
