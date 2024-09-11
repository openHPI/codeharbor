# frozen_string_literal: true

class ModelSolution < ApplicationRecord
  include FileConcern
  belongs_to :task, autosave: true, inverse_of: :model_solutions
  validates :xml_id, presence: true
  validates :xml_id, uniqueness: {scope: :task_id}

  def duplicate
    dup.tap do |model_solutions|
      model_solutions.files = files.map(&:duplicate)
    end
  end
end
