# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    alias_action :create, :show, :update, :destroy, to: :crud

    # Admin abilities
    admin_abilities user

    # AccountLink
    account_link_abilities user

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
  end

  def admin_abilities(user)
    return unless user.role == 'admin'

    can :access, :rails_admin

    can :manage, :all
  end

  def account_link_abilities(user)
    can %i[create new], AccountLink

    can %i[crud view], AccountLink, user_id: user.id
    can %i[view show remove_account_link], AccountLink, shared_users: {id: user.id}
  end

  def cart_abilities(user)
    can %i[create], Cart
    can %i[my_cart show remove_all download_all push_cart export remove_exercise], Cart, user_id: user.id
  end

  def collection_abilities(user)
    can %i[create view_shared save_shared index], Collection
    can %i[crud remove_exercise remove_all push_collection download_all share], Collection, users: {id: user.id}
  end

  def exercise_abilities(user)
    can %i[index create contribute read_comments related_exercises import_exercise_start import_exercise_confirm], Exercise
    can %i[show add_to_cart add_to_collection push_external duplicate download_exercise], Exercise do |exercise|
      exercise.can_access(user)
    end
    alias_action :export_external_start, :export_external_check, :export_external_confirm, to: :export
    can %i[crud export history remove_state], Exercise, user: {id: user.id}
    can %i[crud export history remove_state], Exercise, exercise_authors: {user: {id: user.id}}
    can %i[report], Exercise do |exercise|
      ExerciseAuthor.where(user: user, exercise: exercise).empty? && exercise.user != user
    end
  end

  def comment_abilities(user)
    can %i[show create read answer], Comment
    can %i[crud], Comment, user: {id: user.id}
  end

  def group_abilities(user)
    can %i[create index], Group
    cannot %i[request_access], Group
    can %i[request_access], Group do |group|
      !user.in_group?(group)
    end
    cannot %i[leave], Group
    can %i[leave], Group do |group|
      user.in_group?(group)
    end

    can %i[view show members], Group do |group|
      group.confirmed_member?(user)
    end
    can %i[crud remove_exercise grant_access delete_from_group deny_access make_admin add_account_link_to_member
           remove_account_link_from_member], Group do |group|
      group.admin?(user)
    end
  end

  def user_abilities(user)
    can %i[show view], User
    can %i[message], User do |this_user|
      this_user != user
    end
    can %i[edit update soft_delete delete manage_accountlinks remove_account_link], User, id: user.id
  end

  def message_abilities(user)
    can %i[create], Message
    can %i[show reply delete], Message, recipient: {id: user.id}
    can %i[show delete], Message, sender: {id: user.id}
  end
end
