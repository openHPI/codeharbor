class ExerciseFile < ActiveRecord::Base
  belongs_to :exercise
  has_many :tests, dependent: :destroy

  def full_file_name
    "#{self.file_name}.#{self.file_extension}"
  end

end
