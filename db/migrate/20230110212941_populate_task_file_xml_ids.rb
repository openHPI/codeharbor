# frozen_string_literal: true

class PopulateTaskFileXmlIds < ActiveRecord::Migration[6.1]
  class Task < ApplicationRecord
    has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy
    has_many :tests, dependent: :destroy
    has_many :model_solutions, dependent: :destroy

    def all_files
      (files + tests.map(&:files) + model_solutions.map(&:files)).flatten
    end
  end

  class TaskFile < ApplicationRecord
    belongs_to :fileable, polymorphic: true
    validates :xml_id, presence: true
  end

  class Test < ApplicationRecord
    has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy
  end

  class ModelSolution < ApplicationRecord
    has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy
  end

  # rubocop:disable Rails/SkipsModelValidations
  def up
    Task.find_each do |task|
      task.all_files.each_with_index do |file, index|
        file.update_attribute(:xml_id, index)
      end
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
