# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    []
  end
end
