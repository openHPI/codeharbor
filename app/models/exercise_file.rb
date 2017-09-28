class ExerciseFile < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :file_type
  has_many :tests, dependent: :destroy

  accepts_nested_attributes_for :tests

  def full_file_name
    "#{self.path}/#{self.name}#{self.file_type.file_extension}"
  end

  ROLES = [
      'Main File',
      'Reference Implementation',
      'Regular File',
      'User-defined Test'
  ]

  ROLES.freeze

end
