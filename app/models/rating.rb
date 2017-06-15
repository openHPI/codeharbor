class Rating < ActiveRecord::Base
  validates_numericality_of :rating, :only_integer => true, :less_than_or_equal_to => 5

  belongs_to :exercise
  belongs_to :user
end
