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

  # While discard_changes? and show? look similar, the difference in paraphrases position is relevant
  # discard_changes? can only be executed while the task_contribution is pending by either the owner of the base task or the contrib author
  # show? the author of the contrib can view it, while it is pending while the owner
  def discard_changes?
    task_contribution.pending? && (record_owner? || Pundit.policy(@user, base).edit?)
  end

  def show?
    (task_contribution.pending? && record_owner?) || Pundit.policy(@user, base).edit?
  end

  def approve_changes?
    Pundit.policy(@user, base).edit? && task_contribution.pending?
  end

  %i[edit? update?].each do |action|
    define_method(action) do
      record_owner? && task_contribution.pending?
    end
  end

  def destroy?
    false
  end

  private

  def record_owner?
    @user.present? && @user == suggestion.user
  end
end
