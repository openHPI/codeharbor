# frozen_string_literal: true

class Test < ApplicationRecord
  include TransferValues
  include ParentValidation

  belongs_to :task
  belongs_to :testing_framework, optional: true
  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy
  accepts_nested_attributes_for :files, allow_destroy: true
  validates :title, presence: true
  validates :xml_id, presence: true
  validates :parent_id, uniqueness: {scope: :task}
  validate :parent_validation_check
  # TODO: For new tasks, this validation is currently useless, because the validation is performed
  # before the task is saved (and thus the task_id is not yet known, i.e., is NULL). Therefore,
  # one can create a **new task** with a test that has the same xml_id as another test of the same task.
  validates :xml_id, uniqueness: {scope: :task_id}

  def configuration_as_xml
    Dachsfisch::JSON2XMLConverter.perform(json: configuration.to_json)
  end

  def duplicate
    dup.tap do |test|
      test.files = files.map(&:duplicate)
      test.parent_id = id
    end
  end
end
