# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # # AccountLink
    # account_link_abilities user

    # # Answer
    # answer_abilities user

    # # Cart
    # cart_abilities user

    # # Collection
    # collection_abilities user

    # # Exercise
    # exercise_abilities user

    # # Comment
    # comment_abilities user

    # # Rating
    # can %i[read create], Rating

    # # Groups
    # group_abilities user

    # # User
    # user_abilities user

    # # Message
    # message_abilities user

    # Admin abilities in the end to take precedence
    admin_abilities user
  end

  def admin_abilities(user)
    return unless user.role == 'admin'

    can :access, :rails_admin
    can :read, :dashboard

    can :manage, :all
    # Define Abilities admins cannot do
    # Group
    cannot :leave, Group do |group|
      !user.in_group?(group)
    end
  end

  def account_link_abilities(user)
    can %i[create new], AccountLink
    # can [:manage], AccountLink, :user_id => user.id
    can [:view, :remove_account_link], AccountLink do |account_link|
      account_link.external_users.include?(user)
    end
    can [:manage], AccountLink do |account_link|
      account_link.user == user
    end
  end

  def answer_abilities(user)
    can [:new], Answer
    can [:manage], Answer do |answer|
      answer.user == user
    end
  end

  def cart_abilities(user)
    can [:create], Cart
    can [:my_cart, :show, :remove_all, :download_all, :push_cart, :export, :remove_exercise], Cart do |cart|
      cart.user == user
    end
  end

  def collection_abilities(user)
    can %i[create view_shared save_shared show], Collection
    can [:manage], Collection do |collection|
      collection.users.include?(user)
    end
    cannot :collections_all, Collection
  end

  def exercise_abilities(user)
    can %i[index create contribute read_comments related_exercises], Exercise
    can [:read, :add_to_cart, :add_to_collection, :push_external, :duplicate, :download_exercise, :report], Exercise do |exercise|
      exercise.can_access(user)
    end
    can [:manage], Exercise do |exercise|
      ExerciseAuthor.where(user: user, exercise: exercise).any? || exercise.user == user
    end
    cannot [:report], Exercise do |exercise|
      ExerciseAuthor.where(user: user, exercise: exercise).any? || exercise.user == user
    end
    cannot :exercises_all, Exercise
  end

  def comment_abilities(user)
    can %i[show create read answer], Comment
    can [:manage], Comment do |comment|
      comment.user == user
    end

    cannot :comments_all, Comment
  end

  def group_abilities(user)
    can %i[create request_access], Group
    can [:view, :read, :members, :admins, :leave], Group do |group|
      user.in_group?(group, as: 'member')
    end
    can [:manage], Group do |group|
      user.in_group?(group, as: 'admin')
    end
    cannot [:request_access], Group do |group|
      user.in_group?(group)
    end
    cannot :groups_all, Group
  end

  def user_abilities(user)
    can %i[create view show], User
    can [:message], User do |this_user|
      this_user != user
    end
    can [:edit, :update, :soft_delete, :delete, :manage_accountlinks, :remove_account_link], User do |this_user|
      this_user == user
    end
  end

  def message_abilities(user)
    can [:create], Message
    can [:show, :reply, :delete, :add_author], Message do |message|
      message.recipient == user
    end
    can [:show, :delete], Message do |message|
      message.sender == user
    end
  end
end
