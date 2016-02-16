class ExerciseFile < ActiveRecord::Base
  belongs_to :exercise

  def full_file_name
    "#{self.file_name}.#{self.file_extension}"
  end

end
