class Collection < ActiveRecord::Base
  validates :title, presence: true

  belongs_to :user
  has_and_belongs_to_many :exercises
end
