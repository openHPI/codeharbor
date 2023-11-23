# frozen_string_literal: true

class TaskPolicy < ApplicationPolicy
  def task
    @record
  end

  def user_required?
    false
  end
  private :user_required?

  def show?
    if @user.present?
      admin? || task.access_level_public? || task.in_same_group?(@user) || task.author?(@user)
    else
      task.access_level_public?
    end
  end

  %i[index? new? import_start? import_confirm? import_uuid_check? import_external?].each do |action|
    define_method(action) { everyone }
  end

  %i[create?].each do |action|
    define_method(action) { record_owner? || admin? } # should import_uuid_check and import_external be public?
  end

  %i[download? add_to_collection? duplicate? export_external_start? export_external_check? export_external_confirm?].each do |action|
    define_method(action) do
      return false if @user.blank?

      record_owner? || task.access_level_public? || task.in_same_group?(@user) || admin?
    end
  end

  def update?
    return false if @user.blank?

    record_owner? || task.in_same_group?(@user) || admin?
  end

  def edit?
    update?
  end

  def destroy?
    record_owner? || task.in_same_group_admin?(@user) || admin?
  end
end
