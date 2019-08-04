# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :be_an_equal_exercise_as do |exercise|
  match do |actual|
    equal?(actual, exercise)
  end
  @last_checked
  failure_message do |actual|
    "#{actual.inspect} is not equal to \n#{exercise.inspect}. \nLast checked attribute: #{@last_checked}"
  end

  def equal?(object, other)
    return false unless object.class == other.class
    return attributes_equal?(object, other) if object.is_a?(ApplicationRecord)
    return array_equal?(object, other) if object.is_a?(Array) || object.is_a?(ActiveRecord::Associations::CollectionProxy)

    object == other
  end

  def attributes_equal?(object, other)
    other_attributes = attributes_and_associations(other)
    attributes_and_associations(object).each do |k, v|
      @last_checked = "#{k}: \n#{v} vs \n#{other_attributes[k]}"
      return false unless equal?(other_attributes[k], v)
    end
    true
  end

  def array_equal?(object, other)
    return true if object == other # for []
    return false if object.length != other.length

    object.to_a.product(other.to_a).map { |k, v| equal?(k, v) }.any?
  end

  def attributes_and_associations(object)
    object.attributes.dup.tap do |attributes|
      attributes[:exercise_files] = object.exercise_files if defined? object.exercise_files
      attributes[:descriptions] = object.descriptions if defined? object.descriptions
      attributes[:tests] = object.tests if defined? object.tests
    end.except('id', 'created_at', 'updated_at', 'exercise_id', 'attachment_updated_at', 'exercise_file_id',
               'license_id', 'private', 'tag_list')
  end
end
