class CreateUserIdentity < ActiveRecord::Migration[6.1]
  def change
    create_table :user_identities, id: :uuid, force: :cascade do |t|
      t.belongs_to :user, foreign_key: true, null: false, index: true
      t.string :omniauth_provider
      t.string :provider_uid
      t.timestamps

      t.index %i[omniauth_provider provider_uid], unique: true
    end
  end
end
