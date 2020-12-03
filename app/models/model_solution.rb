# frozen_string_literal: true

class ModelSolution < ApplicationRecord
  belongs_to :task
  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy
  accepts_nested_attributes_for :files, allow_destroy: true

end
