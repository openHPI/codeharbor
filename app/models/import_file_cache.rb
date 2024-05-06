# frozen_string_literal: true

class ImportFileCache < ApplicationRecord
  belongs_to :user

  has_one_attached :zip_file
end
