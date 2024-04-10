# frozen_string_literal: true

class TaskContributionPolicy < ApplicationPolicy
  def task_contribution
    @record
  end

  def suggestion
    @record.suggestion
  end

  def base
    @record.base
  end

  %i[create? new?].each do |action|
    define_method(action) do
      Pundit.policy(@user, base).contribute?
    end
  end

  %i[show? discard_changes?].each do |action|
    define_method(action) do
      record_owner? || (Pundit.policy(@user, base).edit? && task_contribution.pending?)
    end
  end

  def approve_changes?
    Pundit.policy(@user, base).edit? && task_contribution.pending?
  end

  %i[edit? update? destroy?].each do |action|
    define_method(action) do
      record_owner?
    end
  end

  private

  def record_owner?
    @user.present? && @user == suggestion.user
  end
end
