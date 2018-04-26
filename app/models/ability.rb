class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.role == 'admin'
        can :manage, :all
      end

      #AccountLink
      can [:new], AccountLink
      can [:manage], AccountLink do |account_link|
        account_link.user = user
      end
      #Answer
      can [:new], Answer
      can [:manage], Answer do |answer|
        answer.user == user
      end

      #Cart
      can [:create], Cart
      can [:my_cart, :show, :remove_all, :download_all, :remove_exercise], Cart do |cart|
        cart.user == user
      end

      #Collection
      can [:create, :view_shared, :save_shared, :show], Collection
      can [:manage], Collection do |collection|
        collection.users.include?(user)
      end

      #Exercise
      can [:create, :contribute, :read_comments, :related_exercises], Exercise
      can [:show, :read, :add_to_cart, :add_to_collection, :push_external, :duplicate, :download_exercise, :report], Exercise do |exercise|
        exercise.can_access(user)
      end
      can [:manage], Exercise do |exercise|
        ExerciseAuthor.where(user_id: user.id, exercise_id: exercise.id).any? || exercise.user == user
      end
      cannot [:report], Exercise do |exercise|
        ExerciseAuthor.where(user_id: user.id, exercise_id: exercise.id).any? || exercise.user == user
      end

      #Comment
      can [:show, :create, :read, :answer ], Comment
      can [:manage], Comment do |comment|
        comment.user == user
      end

      #Rating
      can [:read, :create], Rating

      #Groups
      can [:create, :request_access], Group
      can [:view, :read, :members, :admins, :leave], Group do |group|
        user.in_group?(group, as: 'member')
      end
      can [:manage], Group do |group|
        user.in_group?(group, as: 'admin')
      end

      #User
      can [:create, :view, :show], User
      can [:message], User do |this_user|
        this_user != user
      end
      can [:edit, :update, :delete, :manage_accountlinks], User do |this_user|
        this_user == user
      end

      #Message
      can [:create], Message
      can [:show, :reply, :delete, :add_author], Message do |message|
        message.recipient == user
      end
      can [:show, :delete], Message do |message|
        message.sender == user
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