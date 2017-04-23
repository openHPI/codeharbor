class Group < ActiveRecord::Base

  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :exercise_group_accesses
  has_many :exercises, through: :exercise_group_access
  
  def admins
    User.find(UserGroup.where(group_id: id, is_admin: true).collect(&:user_id))
  end

  def is_admin(user)
    UserGroup.find_by(group_id: id, user: user).is_admin
  end
  
  def destroy
    UserGroup.destroy_all(group_id: id)
    super
  end

  def users
    User.find(UserGroup.where(group_id: id, is_active: true).collect(&:user_id))
  end

  def pending_users
    User.find(UserGroup.where(group_id: id, is_active: false).collect(&:user_id))
  end
end