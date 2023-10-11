# frozen_string_literal: true

class RemoveTestMetaDataDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :tests, :meta_data, from: '{}', to: nil
  end
end
