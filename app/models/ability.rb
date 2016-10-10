class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.role == 'admin'
        can :manage, :all
      end
      
      #Exercise
      can [:show, :create], Exercise
      can [:manage], Exercise do |exercise|
        ExerciseAuthor.where(user_id: user.id, exercise_id: exercise.id).any?
      end
      
      can [:read, :add_to_cart, :export, :duplicate], Exercise do |exercise| 
        exercise.can_access(user)
      end
      
      #Comment
      can [:show, :create, :read ], Comment
      can [:edit], Comment do |comment|
        comment.user == user
      end
      
      #Rating
      can [:read, :create], Rating
      
      # Groups
      can [:create, :join], Group
      can [:read, :members, :admins, :leave, :condition_for_changing_member_status], Group do |group|
        user.groups.include? group
      end
      can [:update, :destroy, :invite_group_members, :add_administrator, :demote_administrator, :remove_group_member, :all_members_to_administrators], Group do |group|
        UserGroup.where(user_id: user.id, group_id: group.id, is_admin: true).any?
      end
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
