class CreateTaskFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :task_files do |t|
      t.text 'content'
      t.string 'path'
      t.string 'name'
      t.string 'internal_description'
      t.string 'mime_type'
      t.boolean 'used_by_grader'
      t.string 'visible'
      t.string 'usage_by_lms'


      t.timestamps
    end
  end
end
