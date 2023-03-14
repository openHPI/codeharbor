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

    GroupMembershipOld.where(member_type: 'User').and(GroupMembershipOld.where.not(membership_type: nil)).each do |gmo|
      roles = {'admin' => 2, 'member' => 1, 'pending' => 0}
      GroupMembership.create(group_id: gmo.group_id, user_id: gmo.member_id, role: roles[gmo.membership_type])
    end
    GroupMembershipOld.where(member_type: 'Task').each do |gmo|
      GroupTask.create(group_id: gmo.group_id, task_id: gmo.member_id)
    end
  end
end
