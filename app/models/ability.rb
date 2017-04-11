class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.role == 'admin'
        can :manage, :all
      end

      #Answer
      can [:new], Answer
      can [:manage], Answer do |answer|
        answer.user == user
      end

      #Cart
      can [:create], Cart
      can [:manage], Cart do |cart|
        cart.user == user
      end

      #Collection
      can [:create], Collection
      can [:manage], Collection do |collection|
        collection.user == user
      end

      #Exercise
      can [:create], Exercise
      can [:manage, :edit], Exercise do |exercise|
        ExerciseAuthor.where(user_id: user.id, exercise_id: exercise.id).any?
      end
      can [:show, :read, :add_to_cart, :add_to_collection, :export, :duplicate], Exercise do |exercise|
        exercise.can_access(user)
      end

      #Comment
      can [:show, :create, :read, :answer ], Comment
      can [:edit], Comment do |comment|
        comment.user == user
      end

      #Rating
      can [:read, :create], Rating

      #Groups
      can [:create, :request_access], Group
      can [:read, :members, :admins, :leave], Group do |group|
        user.groups.include? group
      end
      can [:update, :destroy, :make_admin, :grant_access, :delete_from_group], Group do |group|
        UserGroup.where(user_id: user.id, group_id: group.id, is_admin: true).any?
      end

      #User
      can [:create], User
      can [:show, :edit, :delete], User do |this_user|
        this_user == user
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