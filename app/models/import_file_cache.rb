# frozen_string_literal: true

class ImportFileCache < ApplicationRecord
  belongs_to :user

  # has_attached_file :zip_file
  has_one_attached :zip_file
  # do_not_validate_attachment_file_type :zip_file
end
