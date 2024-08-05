# frozen_string_literal: true

class AddProformaVersionToAccountLink < ActiveRecord::Migration[7.1]
  def change
    add_column :account_links, :proforma_version, :string
  end
end
