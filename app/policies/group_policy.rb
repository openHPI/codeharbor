# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def group
    @record
  end

  %i[new? index?].each do |action|
    define_method(action) { everyone }
  end

  %i[show? members?].each do |action|
    define_method(action) { admin? || group.confirmed_member?(user) || group.admin?(user) }
  end

  %i[create? update? edit? destroy? remove_task? add_task? delete_from_group? grant_access? deny_access? make_admin?
     demote_admin?].each do |action|
    define_method(action) { admin? || group.admin?(user) }
  end

  def request_access?
    group.users.exclude?(@user)
  end

  def leave?
    group.users.include?(user)
  end
end
