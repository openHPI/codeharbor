class ExerciseFile < ApplicationRecord
  belongs_to :exercise
  belongs_to :file_type
  has_many :tests, dependent: :destroy
  has_attached_file :attachment, :styles => lambda{ |a| ["image/jpeg", "image/png", "image/giv"].include?( a.content_type ) ? { :large => "900x" } : {}  }
  do_not_validate_attachment_file_type :attachment
  validates :name, presence: true

  before_save :parse_text_data

  accepts_nested_attributes_for :tests

  def full_file_name
    filename = ''
    filename += "#{self.path}/" unless self.path.blank?
    filename += "#{self.name}#{self.file_type.file_extension}"
    return filename
  end

  ROLES = [
      'Main File',
      'Reference Implementation',
      'Regular File',
      'User-defined Test'
  ]

  ROLES.freeze

  def parse_text_data
    puts attachment.content_type
    if attachment.instance.attachment_content_type =~ %r((text/)|(application/xml))
      self.content = Paperclip.io_adapters.for(self.attachment.instance.attachment).read
      self.attachment = nil
    end
  end

  def has_attached_image?
    self.attachment.try(:content_type) =~ %r((image/jpeg)|(image/gif)|(image/png))
  end
end
