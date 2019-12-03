# frozen_string_literal: true

class Test < ApplicationRecord
  belongs_to :testing_framework, optional: true
  belongs_to :exercise
  belongs_to :exercise_file, inverse_of: :tests
  accepts_nested_attributes_for :exercise_file, allow_destroy: true

  def content
    exercise_file&.content || ''
  end

  def name
    exercise_file&.name || ''
  end

  def path
    exercise_file&.path || ''
  end

  def file_type_id
    exercise_file&.file_type_id || ''
  end

  def file_type
    exercise_file&.file_type
  end

  def full_file_name
    exercise_file&.full_file_name
  end

  def attachment
    exercise_file&.attachment
  end

  def attached_image?
    if exercise_file
      exercise_file.attached_image?
    else
      false
    end
  end

  def duplicate
    test_duplicate = dup
    test_duplicate.exercise_file = exercise_file.duplicate
    test_duplicate
  end
end
