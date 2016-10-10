class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  has_secure_password

  has_many :account_links
  has_many :exercises
  has_one :cart
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :exercise_authors, dependent: :destroy
  has_many :exercises, through: :exercise_authors
  
  before_destroy :handle_group_memberships, prepend: true


  def cart_count
    if cart
      return cart.exercises.size
    else
      return 0
    end
  end
  
  def is_author?(exercise)
    exercise_authors = User.find(ExerciseAuthor.where(exercise_id: exercise.id).collect(&:user_id))
    return exercise_authors.include? self
  end

  def name
    "#{first_name} #{last_name}"
  end
  
  def has_access_through_any_group?(exercise)
    groups = Group.find(UserGroup.where(user_id: id).collect(&:group_id))
    groups_with_access = Group.find(ExerciseGroupAccess.where(exercise_id: exercise.id).collect(&:group_id))
    return (not (groups & groups_with_access).empty?)
  end
  
  def handle_group_memberships
    groups.each do |group|
      if group.users.count > 1
        if UserGroup.find_by(group: group, user: self).is_admin
          if UserGroup.where(group: group, is_admin: true).count == 1
            return false
          end
        end
      else
        group.destroy
      end
    end
  end
  
  def groups_sorted_by_admin_state_and_name(groups_to_sort = groups)
    groups_to_sort.sort_by do |group|
      [group.admins.include?(self) ? 0 : 1, group.name]
    end
  end
end
