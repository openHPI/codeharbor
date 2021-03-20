# frozen_string_literal: true

class Test < ApplicationRecord
  belongs_to :task
  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy
  accepts_nested_attributes_for :files, allow_destroy: true
  validates :title, presence: true
  validates :xml_id, presence: true
  validates :xml_id, uniqueness: {scope: :task_id}
end
