class User < ActiveRecord::Base
  groupify :group_member
  groupify :named_group_member

  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  has_secure_password

  has_many :collections, dependent: :destroy
  has_many :account_links
  has_many :exercises
  has_one :cart, dependent: :destroy
  has_many :exercise_authors, dependent: :destroy
  has_many :exercises, through: :exercise_authors
  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id'
  has_many :received_messages, :class_name => 'Message', :foreign_key => 'recipient_id'
  
  before_destroy :handle_group_memberships, prepend: true


  def last_admin? (group)
    if self.in_group?(group, as: 'admin')
      if group.admins.size == 1
        true
      end
    end
    false
  end

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
    self.shares_any_group?(exercise)
  end
  
  def handle_group_memberships

    self.in_all_groups?(as: 'admin')

    self.groups.each do |group|
      if group.users.size > 1
        if self.in_group?(group, as: 'admin')
          if group.admins.size == 1
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
