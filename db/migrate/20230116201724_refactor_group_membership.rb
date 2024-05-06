# frozen_string_literal: true

class RefactorGroupMembership < ActiveRecord::Migration[6.1]
  def up
    rename_table :group_memberships, :group_memberships_old

    create_table :group_memberships, id: :uuid, force: :cascade do |t|
      t.belongs_to :user, foreign_key: true, null: false, index: true
      t.belongs_to :group, foreign_key: true, null: false, index: true
      t.integer :role, limit: 1, null: false, default: 0, comment: 'Used as enum in Rails'
      t.timestamps
    end

    GroupMembershipOld.where(member_type: 'User').where.not(membership_type: nil).find_each do |gmo|
      roles = {'admin' => :admin, 'member' => :confirmed_member, 'pending' => :applicant}
      GroupMembership.create(group_id: gmo.group_id, user_id: gmo.member_id, role: roles[gmo.membership_type])
    end

    GroupMembershipOld.where(member_type: 'Task').find_each do |gmo|
      GroupTask.create(group_id: gmo.group_id, task_id: gmo.member_id)
    end

    drop_table :group_memberships_old
  end
end

class GroupMembershipOld < ApplicationRecord
  self.table_name = 'group_memberships_old'
end
