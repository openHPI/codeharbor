# frozen_string_literal: true

class TaskFile < ApplicationRecord
  belongs_to :fileable, polymorphic: true

  has_one_attached :attachment
  validates :name, presence: true
  validates :attachment, presence: true, if: -> { use_attached_file == 'true' }, on: :force_validations

  attr_accessor :use_attached_file

  before_save :remove_attachment

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

  private

  def remove_attachment
    attachment.purge if use_attached_file != 'true' && attachment.present?
  end

  def extract_text_data
    return unless attachment.attached?

    return unless %r{(text/)|(application/xml)}.match?(attachment.content_type)

    self.content = attachment.blob.download
    attachment.purge
    save!
  end
end
