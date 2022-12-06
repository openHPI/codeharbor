# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :members, through: :group_memberships
  has_many :group_memberships, dependent: :destroy

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

  def admin?(user)
    user.in_group?(self, as: 'admin')
  end

  def confirmed_member?(user)
    user.in_group?(self) unless user.in_group?(self, as: 'pending')
  end

  def member?(user)
    user.in_group?(self, as: 'member')
  end

  def make_admin(user)
    users.delete(user)
    add(user, as: 'admin')
  end

  def grant_access(user)
    users.delete(user)
    add(user, as: 'member')
  end

  def add_pending_user(user)
    add(user, as: 'pending')
  end

  def admins
    User.in_group(self).as(:admin)
  end

  def confirmed_members
    User.in_group(self).as(:member) | User.in_group(self).as(:admin)
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
