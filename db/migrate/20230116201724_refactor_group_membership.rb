# frozen_string_literal: true

class RefactorGroupMembership < ActiveRecord::Migration[6.1]
  def up
    rename_table :group_memberships, :group_memberships_old

    create_table :group_memberships, id: :serial, force: :cascade do |t|
      t.belongs_to :user, foreign_key: true, null: false, index: true
      t.belongs_to :group, foreign_key: true, null: false, index: true
      t.integer :role, default: 0, null: false
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
    remove_column :groups, :membership_type, :string
  end
end
