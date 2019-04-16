# frozen_string_literal: true

class Group < ApplicationRecord
  groupify :group, members: %i[users exercises], default_members: :users
  validates :name, presence: true

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
end
