# frozen_string_literal: true

class CollectionTask < ApplicationRecord
  belongs_to :collection
  belongs_to :task
end
