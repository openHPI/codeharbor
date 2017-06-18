class ExerciseFile < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :file_type
  has_many :tests, dependent: :destroy

  def full_file_name
    "#{self.name}"

    # Old full_file_name: "#{self.file_name}.#{self.file_extension}"
  end

  ROLES = [
      'Main File',
      'Reference Implementation',
      'Regular File',
      'User-defined Test'
  ]

  ROLES.freeze

end
