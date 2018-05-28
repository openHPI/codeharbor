class AddAttachmentAttachmentToExerciseFiles < ActiveRecord::Migration
  def self.up
    change_table :exercise_files do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :exercise_files, :attachment
  end
end
