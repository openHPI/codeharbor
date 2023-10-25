# frozen_string_literal: true

class TaskFile < ApplicationRecord
  include ParentValidation

  belongs_to :fileable, polymorphic: true, autosave: true, inverse_of: :files

  has_one_attached :attachment
  validates :name, presence: true
  validates :attachment, presence: true, if: -> { use_attached_file == 'true' }, on: :force_validations
  validates :xml_id, presence: true
  validates :visible, inclusion: {in: %w[yes no delayed]}
  validates :used_by_grader, inclusion: {in: [true, false]}
  validates :parent_id, uniqueness: {scope: %i[fileable_id fileable_type]}, if: -> { parent_id.present? }
  validate :unique_xml_id, if: -> { !fileable.nil? && xml_id_changed? }
  validate :parent_validation_check
  attr_accessor :use_attached_file, :file_marked_for_deletion

  before_save :remove_attachment

  def task
    if fileable.is_a?(Task)
      # This file is directly attached to a task
      fileable
    else
      # This file is part of a model solution, or test
      fileable.task
    end
  end

  def full_file_name
    path.present? ? File.join(path.to_s, name) : name
  end

  def full_file_name=(full_file_name)
    path = File.dirname(full_file_name)
    self.path = path == '.' ? '' : path
    self.name = File.basename(full_file_name)
  end

  def duplicate
    dup.tap do |file|
      file.attachment.attach(attachment.blob) if attachment.attached?
      file.parent_id = id
    end
  end

  def text_data?
    return false unless (content = attachment&.blob&.download)

    content.encode('UTF-8', 'binary')
    true
  rescue Encoding::UndefinedConversionError => _e
    false
  end

  def extract_text_data
    attachment.blob.download
  end

  private

  def remove_attachment
    attachment.purge if use_attached_file != 'true' && attachment.present?
  end

  def unique_xml_id
    task = fileable.is_a?(Task) ? fileable : fileable.task
    xml_ids = (task.all_files(cached: false) - [self]).map(&:xml_id)
    errors.add(:xml_id, :not_unique) if xml_ids.include? xml_id
  end
end
