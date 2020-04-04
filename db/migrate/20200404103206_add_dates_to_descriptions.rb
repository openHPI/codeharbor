class AddDatesToDescriptions < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :descriptions, null: true #TODO better default than null?
  end
end
