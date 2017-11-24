class ExerciseFile < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :file_type
  has_many :tests, dependent: :destroy
  has_attached_file :attachment
  do_not_validate_attachment_file_type :attachment

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

end
