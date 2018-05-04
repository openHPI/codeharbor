class Test < ApplicationRecord
  belongs_to :testing_framework
  belongs_to :exercise
  belongs_to :exercise_file
  accepts_nested_attributes_for :exercise_file, allow_destroy: true

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
    file_type = nil
    file_type = exercise_file.file_type if exercise_file
  end

  def attachment
    attachment = nil
    attachment = exercise_file.attachment if exercise_file
  end

  def has_attached_image?
    if exercise_file
      exercise_file.attachment.try(:content_type) =~ %r((image/jpeg)|(image/gif)|(image/png))
    else
      false
    end
  end

  def full_file_name
    exercise_file.try(:full_file_name)
  end
end
