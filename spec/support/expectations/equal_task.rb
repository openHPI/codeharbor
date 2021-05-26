# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :be_an_equal_task_as do |task2|
  match do |task1|
    equal?(task1, task2)
  end
  failure_message do |actual|
    "#{actual.inspect} is not equal to \n#{task2.inspect}. \nLast checked attribute: #{@last_checked}"
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
      @last_checked = "#{k}: \n'#{v}' vs \n'#{other_attributes[k]}'"
      return false unless equal?(other_attributes[k], v)
    end
    true
  end

  # rubocop:disable Metrics/AbcSize
  def array_equal?(object, other)
    return true if object == other # for []
    return false if object.length != other.length

    object_clone = object.to_a.clone
    other_clone = other.to_a.clone
    object.each do |element|
      object_index = object_clone.index(element)
      other_index = other_clone.index { |delete_element| equal?(element, delete_element) }
      return false if other_index.nil?

      object_clone.delete_at(object_index)
      other_clone.delete_at(other_index)
    end
    object_clone.empty? && other_clone.empty?
  end
  # rubocop:enable Metrics/AbcSize

  def attributes_and_associations(object)
    object.attributes.dup.tap do |attributes|
      attributes[:files] = object.files if defined? object.files
      attributes[:tests] = object.tests if defined? object.tests
      attributes[:model_solutions] = object.model_solutions if defined? object.model_solutions
    end.except('id', 'created_at', 'updated_at', 'task_id', 'task_file_id', 'uuid', 'fileable_id')
  end
end
