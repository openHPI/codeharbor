# frozen_string_literal: true

module FileConcern
  extend ActiveSupport::Concern

  included do
    has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy, autosave: true, inverse_of: :fileable
    accepts_nested_attributes_for :files, allow_destroy: true
  end

  def files
    # We need to overwrite the `files` association method to allow moving files between the polymorphic associations.
    # In the default case, a moved file would still be associated with the old record until saved (despite a correct inverse relationship).
    # Therefore, we need to filter the files by the fileable type and only return those are belong to the current record.
    # To minimize the impact and still allow method chaining, we filter only files if the association is already loaded.
    # See https://github.com/openHPI/codeharbor/pull/1606 for more details.
    return super unless association(:files).loaded?

    association(:files).reader.records.filter {|file| file.fileable == self }
  end
end
