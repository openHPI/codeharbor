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

  def discard_changes?
    return no_one unless task_contribution.status_pending?

    record_owner? || admin?
  end

  def show?
    # show? allows the owner of the base task to view it anytime.
    # Simultaneously, the contributor can view it only while the contrib is still pending
    return true if Pundit.policy(@user, base).edit?

    task_contribution.status_pending? && record_owner?
  end

  %i[approve_changes? reject_changes?].each do |action|
    define_method(action) do
      return no_one unless task_contribution.status_pending?

      Pundit.policy(@user, base).edit?
    end
  end

  %i[edit? update?].each do |action|
    define_method(action) do
      return no_one unless task_contribution.status_pending?

      record_owner? || admin?
    end
  end

  def destroy?
    no_one
  end

  private

  def record_owner?
    @user.present? && @user == suggestion.user
  end
end
