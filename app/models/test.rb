# frozen_string_literal: true

class Test < ApplicationRecord
  belongs_to :task
  belongs_to :testing_framework, optional: true
  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy
  accepts_nested_attributes_for :files, allow_destroy: true
  validates :title, presence: true
  validates :xml_id, presence: true
  validates :xml_id, uniqueness: {scope: :task_id}

  def configuration_as_xml
    Dachsfisch::JSON2XMLConverter.perform(json: configuration.to_json)
  end

  def duplicate
    dup.tap do |test|
      test.files = files.map(&:duplicate)
    end
  end
end
