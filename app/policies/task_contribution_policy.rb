# frozen_string_literal: true

class TaskContributionPolicy < ApplicationPolicy
  def initialize(user, record)
    super
    @record = record.task_contribution if record.is_a?(Task)
  end

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

  def index?(base: nil)
    return everyone if @record == TaskContribution

    if base.blank?
      contribution = @record.try(:last) || @record
      base = contribution.try(:base)
      return no_one unless base
    end

    Pundit.policy(@user, base).edit?
  end

  %i[show? download?].each do |action|
    # The policy allows the owner of the base task to perform the action anytime.
    # Simultaneously, the contributor can perform the action only while the contribution is still pending.
    define_method(action) do
      return true if Pundit.policy(@user, base).edit?

      task_contribution.status_pending? && record_owner?
    end
  end

  %i[edit? update?].each do |action|
    define_method(action) do
      return no_one unless task_contribution.status_pending?

      record_owner? || admin?
    end
  end

  def generate_test?
    user.openai_api_key.present? and update?
  end

  %i[approve_changes? reject_changes?].each do |action|
    define_method(action) do
      return no_one unless task_contribution.status_pending?

      Pundit.policy(@user, base).edit?
    end
  end

  def discard_changes?
    return no_one unless task_contribution.status_pending?

    record_owner? || admin?
  end

  %i[add_to_collection? duplicate? manage? destroy?
     import_uuid_check? import_external? import_start? import_confirm?
     export_external_start? export_external_check? export_external_confirm?].each do |action|
    # Those actions are, by design, not allowed on contributions.
    define_method(action) do
      no_one
    end
  end

  def contribute?(*)
    no_one
  end

  private

  def record_owner?
    @user.present? && @user == suggestion.user
  end
end
