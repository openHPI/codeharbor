class Relation < ActiveRecord::Base
  validates :name, presence: true

end
