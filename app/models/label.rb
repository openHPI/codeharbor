class Label < ApplicationRecord
  belongs_to :label_category
  has_and_belongs_to_many :exercises

end
