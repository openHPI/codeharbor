# frozen_string_literal: true

class Group < ApplicationRecord
  groupify :group, members: %i[users exercises], default_members: :users
  validates :name, presence: true
  validate :admin_in_group

  def self.create_with_admin(params, user)
    group = Group.new(params)
    return group unless user

    ActiveRecord::Base.transaction do
      group.save(validate: false)
      group.make_admin(user)
      raise ActiveRecord::Rollback unless group.valid?
    end
    group
  end

  def admins
    User.in_group(self).as(:admin)
  end

  def admin?(user)
    user.in_group?(self, as: 'admin')
  end

  def member?(user)
    user.in_group?(self) unless user.in_group?(self, as: 'pending')
  end

  def make_admin(user)
    add(user, as: 'admin')
  end

  def grant_access(user)
    users.delete(user, as: 'pending')
    add(user, as: 'member')
  end

  def add_pending_user(user)
    add(user, as: 'pending')
  end

  def members
    User.in_group(self).as(:member)
  end

  def pending_users
    User.in_group(self).as(:pending)
  end

  def remove_member(member)
    ActiveRecord::Base.transaction do
      users.destroy(member)
      validate!
    end
  end

  def last_admin?(user)
    user.in_group?(self, as: 'admin') && admins.size == 1
  end

  private

  def admin_in_group
    errors.add(:base, I18n.t('groups.no_admin_validation')) if admins.empty?
  end
end
