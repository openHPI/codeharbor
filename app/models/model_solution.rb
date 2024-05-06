# frozen_string_literal: true

class ModelSolution < ApplicationRecord
  belongs_to :task
  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy
  accepts_nested_attributes_for :files, allow_destroy: true
  validates :xml_id, presence: true
  validates :xml_id, uniqueness: {scope: :task_id}

  def duplicate
    dup.tap do |model_solutions|
      model_solutions.files = files.map(&:duplicate)
    end
  end
end
