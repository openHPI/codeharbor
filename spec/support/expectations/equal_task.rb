# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :be_an_equal_task_as do |task|
  match do |actual|
    equal?(actual, task)
  end
  failure_message do |actual|
    "#{actual.inspect} is not equal to \n#{task.inspect}. \nLast checked attribute: #{@last_checked}"
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

  # rubocop:disable Metrics/CyclomaticComplexity
  def array_equal?(object, other)
    return true if object == other # for []
    return false if object.length != other.length

    object.map do |element|
      other.map do |other_element|
        equal?(element, other_element)
      end.any?
    end.all? && other.map do |element|
      object.map do |other_element|
        equal?(element, other_element)
      end.any?
    end.all?
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def attributes_and_associations(object)
    object.attributes.dup.tap do |attributes|
      attributes[:files] = object.files if defined? object.files
      attributes[:tests] = object.tests if defined? object.tests
      attributes[:model_solutions] = object.model_solutions if defined? object.model_solutions
    end.except('id', 'created_at', 'updated_at', 'task_id', 'task_file_id', 'uuid', 'fileable_id')
  end
end
