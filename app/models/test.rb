class Test < ActiveRecord::Base
  belongs_to :testing_framework
  belongs_to :exercise
  belongs_to :exercise_file

  def content
    if exercise_file
      return exercise_file.content
    else
      return ''
    end
  end
end
