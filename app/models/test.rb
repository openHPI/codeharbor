class Test < ActiveRecord::Base
  belongs_to :testing_framework
  belongs_to :exercise
  belongs_to :exercise_file
end
