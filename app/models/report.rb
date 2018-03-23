class Report < ApplicationRecord
  belongs_to :exercise
  belongs_to :user
end
