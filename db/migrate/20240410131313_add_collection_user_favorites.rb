class AddCollectionUserFavorites < ActiveRecord::Migration[7.1]
  def change
    create_table :collection_user_favorites, id: :uuid, force: :cascade do |t|
      t.belongs_to :collection, foreign_key: true, null: false, index: true
      t.belongs_to :user, foreign_key: true, null: false, index: true
    end
  end
end
