# frozen_string_literal: true

class TaskPolicy < ApplicationPolicy
  def task
    @record
  end

  %i[show? download?].each do |action|
    define_method(action) do
      if @user.present?
        record_owner? || admin? || task.access_level_public? || task_in_group_with?(@user)
      else
        task.access_level_public?
      end
    end
  end

  %i[import_uuid_check? import_external?].each do |action|
    define_method(action) { everyone }
  end

  %i[index? new? import_start? import_confirm?].each do |action|
    define_method(action) { everyone }
  end

  def create?
    record_owner? || admin?
  end

  %i[add_to_collection? duplicate? export_external_start? export_external_check? export_external_confirm?].each do |action|
    define_method(action) do
      return no_one if @user.blank?

      record_owner? || task.access_level_public? || task_in_group_with?(@user) || admin?
    end
  end

  def update?
    return no_one if @user.blank?

    record_owner? || task_in_group_with?(@user) || admin?
  end

  def edit?
    update?
  end

  def destroy?
    record_owner? || admin?
  end

  def manage?
    show? and update? and destroy?
  end

  def generate_test?
    user&.openai_api_key.present? and update?
  end

  def contribute?(check_other_contrib: true)
    return false if @user.blank? # Disallow contributing without an active session (anonymous user).
    return false unless (show? && !edit?) || admin? # Contributing is only allowed if a user cannot make direct changes and is not an admin.
    return true unless check_other_contrib # Allow action, if existing contributions are irrelevant.

    # Contributing is only allowed if no other pending contributions exists.
    task.contributions.joins(:suggestion).where(suggestion: {user: @user}, status: :pending).none?
  end

  private

  def user_required?
    false
  end

  # helper methods
  def task_in_group_with?(user)
    task_in_group_with_member?(user) || task_in_group_with_admin?(user)
  end

  def task_in_group_with_member?(user)
    task.groups.any? {|group| group.confirmed_member?(user) }
  end

  def task_in_group_with_admin?(user)
    task.groups.any? {|group| group.admin?(user) }
  end
end
