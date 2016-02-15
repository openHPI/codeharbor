class AddLanguageToDescription < ActiveRecord::Migration
  def change
    add_column :descriptions, :language, :string, default: 'EN'
  end
end
