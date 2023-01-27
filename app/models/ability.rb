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

    # Collection
    collection_abilities user

    task_abilities user

    task_file_abilities user

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

    can %i[crud view remove_shared_user add_shared_user], AccountLink, user_id: user.id
    can %i[view show remove_shared_user], AccountLink, shared_users: {id: user.id}
  end

  def collection_abilities(user)
    can %i[create view_shared save_shared index], Collection
    cannot %i[leave], Collection
    can %i[crud leave remove_exercise remove_all push_collection download_all share], Collection, users: {id: user.id}
  end

  def task_abilities(user)
    can %i[index create import_start import_confirm], Task

    alias_action :export_external_start, :export_external_check, :export_external_confirm, to: :export
    can %i[crud export download], Task, user: {id: user.id}
  end

  def task_file_abilities(user)
    can %i[download_attachment extract_text_data], TaskFile do |task_file|
      fileable = task_file.fileable
      task = fileable.is_a?(Task) ? fileable : fileable.task
      task.can_access(user)
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
      group.users.exclude?(user)
    end
    cannot %i[leave], Group
    can %i[leave], Group do |group|
      group.users.include?(user)
    end

    can %i[view show members], Group do |group|
      group.confirmed_member?(user) || group.admin?(user)
    end
    can %i[crud remove_task delete_from_group grant_access deny_access make_admin], Group do |group|
      group.admin?(user)
    end
  end

  def user_abilities(user)
    can %i[message], User do |this_user|
      this_user != user
    end
    can %i[edit update soft_delete delete manage_accountlinks remove_account_link show view], User, id: user.id
  end

  def message_abilities(user)
    can %i[create], Message
    can %i[show reply delete], Message, recipient: {id: user.id}
    can %i[show delete], Message, sender: {id: user.id}
  end
end
