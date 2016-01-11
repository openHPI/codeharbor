class Exercise < ActiveRecord::Base
  has_many :exercise_files
  has_many :labels
  has_many :comments
  has_many :ratings
end
