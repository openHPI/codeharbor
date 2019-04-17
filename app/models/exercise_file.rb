# frozen_string_literal: true

class ExerciseFile < ApplicationRecord
  belongs_to :exercise
  belongs_to :file_type
  has_many :tests, dependent: :destroy
  has_attached_file :attachment, styles: ->(a) { ['image/jpeg', 'image/png', 'image/giv'].include?(a.content_type) ? {large: '900x'} : {} }
  do_not_validate_attachment_file_type :attachment
  validates :name, presence: true

  before_save :parse_text_data

  accepts_nested_attributes_for :tests

  def full_file_name
    filename = ''
    filename += "#{path}/" if path.present?
    filename += "#{name}#{file_type.try(:file_extension)}"
    filename
  end

  ROLES = [
    'Main File',
    'Reference Implementation',
    'Regular File',
    'User-defined Test'
  ].freeze

  ROLES.freeze

  def parse_text_data
    # puts attachment.content_type
    return unless %r{(text/)|(application/xml)}.match?(attachment.instance.attachment_content_type)

    self.content = Paperclip.io_adapters.for(attachment.instance.attachment).read
    self.attachment = nil
  end

  def attached_image?
    attachment.try(:content_type) =~ %r{(image/jpeg)|(image/gif)|(image/png)}
  end
end
