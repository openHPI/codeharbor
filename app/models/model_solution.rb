# frozen_string_literal: true

class ModelSolution < ApplicationRecord
  include FileConcern
  include TransferValues

  belongs_to :task, autosave: true, inverse_of: :model_solutions
  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy
  accepts_nested_attributes_for :files, allow_destroy: true
  validates :xml_id, presence: true
  # TODO: For new tasks, this validation is currently useless, because the validation is performed
  # before the task is saved (and thus the task_id is not yet known, i.e., is NULL). Therefore,
  # one can create a **new task** with a test that has the same xml_id as another test of the same task.
  # TODO: This validation is currently useless on new records, because the uuid is generated after validation
  validates :xml_id, uniqueness: {scope: :task_id}

  def duplicate
    dup.tap do |model_solution|
      model_solution.files = files.map(&:duplicate)
      model_solution.parent_id = id
    end
  end
end
