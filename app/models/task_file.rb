# frozen_string_literal: true

class TaskFile < ApplicationRecord
  belongs_to :fileable, polymorphic: true

  has_one_attached :attachment
  validates :name, presence: true
  validates :fileable, presence: true

  after_create_commit :extract_text_data # TODO make this manually initiatable and not based on type?

  def full_file_name
    File.join(path.to_s, name)
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
