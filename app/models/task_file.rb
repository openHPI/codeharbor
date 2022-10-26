# frozen_string_literal: true

class TaskFile < ApplicationRecord
  belongs_to :fileable, polymorphic: true

  has_one_attached :attachment
  validates :name, presence: true

  # after_create_commit :extract_text_data # TODO: make this manually initiatable and not based on type?

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
    end
  end

  def has_text_data?
    return false unless (content = attachment&.blob&.download)
    content.encode('UTF-8', 'binary')
    true
  rescue Encoding::UndefinedConversionError => _e
    false
  end

  def extract_text_data
    attachment.blob.download
  end
end
