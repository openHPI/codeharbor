# frozen_string_literal: true

class ExerciseFile < ApplicationRecord
  belongs_to :exercise, optional: true
  belongs_to :exercise_test, optional: true, inverse_of: :exercise_file, foreign_key: 'test_id', class_name: 'Test'
  belongs_to :file_type
  has_attached_file :attachment, styles: ->(a) { ['image/jpeg', 'image/png', 'image/giv'].include?(a.content_type) ? {large: '900x'} : {} }
  do_not_validate_attachment_file_type :attachment
  validates :name, presence: true
  validates :hidden, inclusion: [true, false]
  validates :read_only, inclusion: [true, false]
  validates :exercise, presence: true, unless: -> { purpose == 'test' }
  validates :exercise_test, presence: true, if: -> { purpose == 'test' }

  before_save :parse_text_data

  ROLES = %w[main_file reference_implementation regular_file teacher_defined_test].freeze
  TEST_ROLE = %w[teacher_defined_test].freeze

  def full_file_name
    filename = ''
    filename += "#{path}/" if path.present?
    filename += "#{name}#{file_type.try(:file_extension)}"
    filename
  end

  def full_file_name=(full_file_name)
    extension = File.extname(full_file_name)
    file_type = FileType.find_by(file_extension: extension)
    raise I18n.t('models.exercise_file.errors.no_filetype', extension: extension) if file_type.nil?

    path = File.dirname(full_file_name)
    self.path = path == '.' ? '' : path
    self.name = File.basename(full_file_name, '.*')
    self.file_type = file_type
  end

  def attached_image?
    !(attachment.try(:content_type) =~ %r{(image/jpeg)|(image/gif)|(image/png)|(image/bmp)}).nil?
  end

  def duplicate(exercise: nil, test: nil)
    exercise_file_duplicate = dup
    exercise_file_duplicate.attachment = attachment
    exercise_file_duplicate.exercise = exercise unless exercise.nil?
    exercise_file_duplicate.exercise_test = test unless test.nil?
    exercise_file_duplicate
  end

  private

  def parse_text_data
    return unless %r{(text/)|(application/xml)}.match?(attachment.instance.attachment_content_type)

    self.content = Paperclip.io_adapters.for(attachment.instance.attachment).read
    self.attachment = nil
  end
end
