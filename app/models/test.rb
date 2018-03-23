class Test < ApplicationRecord
  belongs_to :testing_framework
  belongs_to :exercise
  belongs_to :exercise_file

  def content
    content = ''
    content = exercise_file.content if exercise_file
  end

  def name
    name = ''
    name = exercise_file.name if exercise_file
  end

  def path
    path = ''
    path = exercise_file.path if exercise_file
  end

  def file_type_id
    id = ''
    id = exercise_file.file_type_id if exercise_file
  end

  def file_type
    file_type = ''
    file_type = exercise_file.file_type if exercise_file
  end

end
