# frozen_string_literal: true

class Test < ApplicationRecord
  include FileConcern
  include TransferValues

  belongs_to :task, autosave: true, inverse_of: :tests
  belongs_to :testing_framework, optional: true
  validates :title, presence: true
  validates :xml_id, presence: true

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
