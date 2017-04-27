class Group < ActiveRecord::Base
  groupify :group, members: [:users, :exercises], default_members: :users
  validates :name, presence: true

  #has_many :group_memberships, dependent: :destroy
  #has_many :users, through: :group_memberships
  #has_many :exercise_group_accesses
  #has_many :exercises, through: :exercise_group_access


  def admins
    #Old: User.find(UserGroup.where(group_id: id, is_admin: true).collect(&:user_id))
    User.in_group(self).as(:admin)
  end

  def is_admin(user)
    #Old: UserGroup.find_by(group_id: id, user: user).is_admin
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
    #Old: User.find(UserGroup.where(group_id: id, is_active: true).collect(&:user_id))
    User.in_group(self).as(:member)
  end

  def pending_users
    #Old: User.find(UserGroup.where(group_id: id, is_active: false).collect(&:user_id))
    User.in_group(self).as(:pending)
  end
end
