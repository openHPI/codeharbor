# frozen_string_literal: true

class TaskContributionPolicy < ApplicationPolicy
  def task_contribution
    @record
  end

  def modifying_task
    @record.modifying_task
  end

  def base_task
    @record.base_task
  end

  %i[create? new?].each do |action|
    define_method(action) do
      Pundit.policy(@user, base_task).show? && !Pundit.policy(@user, base_task).edit? && base_task.contributions.where(user: @user).none?
    end
  end

  %i[show? discard_changes?].each do |action|
    define_method(action) do
      record_owner? || (Pundit.policy(@user, base_task).edit? && task_contribution.pending?)
    end
  end

  def approve_changes?
    Pundit.policy(@user, base_task).edit? && task_contribution.pending?
  end

  %i[edit? update? destroy?].each do |action|
    define_method(action) do
      record_owner?
    end
  end

  private

  def record_owner?
    @user.present? && @user == modifying_task.user
  end
end
