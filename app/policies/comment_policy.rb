# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def comment
    @record
  end

  def index?
    task_authorized?
  end

  def new?
    everyone
  end

  %i[create? update? edit? destroy?].each do |action|
    define_method(action) { (record_owner? && task_authorized?) || admin? }
  end

  private

  def user_required?
    false
  end

  def task_authorized?
    if @record.respond_to?(:map)
      @record.map(&:tasks).uniq.all? {|task| Pundit.policy(@user, task).show? }
    else
      Pundit.policy(@user, comment.task).show?
    end
  end
end
