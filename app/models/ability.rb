# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    alias_action :create, :show, :update, :destroy, to: :crud

    # AccountLink
    account_link_abilities user

    # Answer
    answer_abilities user

    # Cart
    cart_abilities user

    # Collection
    collection_abilities user

    # Exercise
    exercise_abilities user

    # Comment
    comment_abilities user

    # Rating
    can %i[read create], Rating

    # Groups
    group_abilities user

    # User
    user_abilities user

    # Message
    message_abilities user

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

    can [:crud], AccountLink, user_id: user.id
    can [:view, :remove_account_link], AccountLink do |account_link|
      account_link.external_users.include?(user)
    end
  end

  def answer_abilities(user)
    can [:new], Answer
    can [:crud], Answer, user_id: user.id
  end

  def cart_abilities(user)
    can [:create], Cart
    can %i[my_cart show remove_all download_all push_cart export remove_exercise], user_id: user.id
  end

  def collection_abilities(user)
    can %i[create view_shared save_shared index], Collection
    can [:crud, :remove_exercise, :remove_all, :push_collection, :download_all, :share], Collection do |collection|
      collection.users.include?(user)
    end
  end

  def exercise_abilities(user)
    can %i[index create contribute read_comments related_exercises], Exercise
    can [:show, :add_to_cart, :add_to_collection, :push_external, :duplicate, :download_exercise], Exercise do |exercise|
      exercise.can_access(user)
    end
    can [:crud, :export_external_start, :export_external_check, :export_external_confirm, :import_exercise_start,
         :import_exercise_confirm, :history], Exercise do |exercise|
      ExerciseAuthor.where(user: user, exercise: exercise).any? || exercise.user == user
    end
    can [:report], Exercise do |exercise|
      ExerciseAuthor.where(user: user, exercise: exercise).empty? && exercise.user != user
    end
  end

  def comment_abilities(user)
    can %i[show create read answer], Comment
    can [:crud], Comment do |comment|
      comment.user == user
    end
  end

  def group_abilities(user)
    can %i[create], Group
    can [:request_access], Group do |group|
      !user.in_group?(group)
    end
    can [:view, :show, :members, :admins, :leave], Group do |group|
      user.in_group?(group, as: 'member')
    end
    can [:crud, :remove_exercise, :grant_access, :delete_from_group, :deny_access, :make_admin], Group do |group|
      # :add_account_link_from_member, :remove_account_link_from_member
      user.in_group?(group, as: 'admin')
    end
  end

  def user_abilities(user)
    can %i[create show], User
    can [:message], User do |this_user|
      this_user != user
    end
    can [:edit, :update, :soft_delete, :delete, :manage_accountlinks, :remove_account_link], User do |this_user|
      this_user == user
    end
  end

  def message_abilities(user)
    can [:create], Message
    can [:show, :reply, :delete], Message do |message|
      message.recipient == user
    end
    can [:show, :delete], Message do |message|
      message.sender == user
    end
  end
end
