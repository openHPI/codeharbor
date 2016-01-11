class Label < ActiveRecord::Base
  belongs_to :label_category
  belongs_to :exercise
end
