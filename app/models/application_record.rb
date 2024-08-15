# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_validation :strip_strings
  before_validation :remove_null_bytes

  def strip_strings
    # trim whitespace from beginning and end of string attributes
    attribute_names.each do |name|
      if send(name.to_sym).respond_to?(:strip)
        send(:"#{name}=", send(name).strip)
      end
    end
  end

  def remove_null_bytes
    # remove null bytes from string attributes
    attribute_names.each do |name|
      if send(name.to_sym).respond_to?(:tr)
        send(:"#{name}=", send(name).tr("\0", ''))
      end
    end
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    []
  end
end
