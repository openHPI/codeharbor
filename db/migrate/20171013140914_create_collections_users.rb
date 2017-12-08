class CreateCollectionsUsers < ActiveRecord::Migration
  def change
    create_table :collections_users do |t|
      t.belongs_to :user, index: true
      t.belongs_to :collection, index: true
    end
  end
end
