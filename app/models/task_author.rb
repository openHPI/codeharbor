# frozen_string_literal: true

class TaskAuthor < ApplicationRecord
  belongs_to :task
  belongs_to :user
end
