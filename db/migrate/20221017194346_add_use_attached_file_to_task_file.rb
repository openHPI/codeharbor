class AddUseAttachedFileToTaskFile < ActiveRecord::Migration[6.1]
  def change
    add_column :task_files, :use_attached_file, :boolean, null: true

    TaskFile.all.each do |file|
      file.update_attribute(:use_attached_file, file.attachment.attached?)
    end

    change_column :task_files, :use_attached_file, :boolean, null: false
  end
end
