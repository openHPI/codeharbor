# frozen_string_literal: true

class Test < ApplicationRecord
  include FileConcern
  belongs_to :task, autosave: true, inverse_of: :tests
  belongs_to :testing_framework, optional: true
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
