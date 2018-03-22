class Group < ApplicationRecord
  groupify :group, members: [:users, :exercises], default_members: :users
  validates :name, presence: true


  def admins
    User.in_group(self).as(:admin)
  end

  def is_admin(user)
    user.in_group?(self, as: 'admin')
  end

  def has_member(user)
    unless user.in_group?(self, as: 'pending')
      user.in_group?(self)
    end
  end

  def make_admin(user)
    self.add(user, as: 'admin')
  end

  def grant_access(user)
    self.users.delete(user, as: 'pending')
    self.add(user, as: 'member')
  end

  def add_pending_user(user)
    self.add(user, as: 'pending')
  end

  def members
    User.in_group(self).as(:member)
  end

  def pending_users
    User.in_group(self).as(:pending)
  end
end
