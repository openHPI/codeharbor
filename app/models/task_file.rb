# frozen_string_literal: true

class TaskFile < ApplicationRecord
  belongs_to :fileable, polymorphic: true

  after_create_commit :extract_text_data
  has_one_attached :attachment

  def full_file_name
    "#{path.present? ? "#{path}/" : ''}#{name}"
  end

  private

  def extract_text_data
    return unless attachment.attached?

    return unless %r{(text/)|(application/xml)}.match?(attachment.content_type)

    self.content = attachment.blob.download
    attachment.purge
    save!
  end
end
