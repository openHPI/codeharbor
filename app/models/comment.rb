class Comment < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :user
end
