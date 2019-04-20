# frozen_string_literal: true

class CartExercise < ApplicationRecord
  belongs_to :cart
  belongs_to :exercise
end
