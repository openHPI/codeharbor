# frozen_string_literal: true

class RatingPolicy < ApplicationPolicy
  def rating
    @record
  end

  def new_for_task?(task)
    @user != task.user
  end

  def create?
    record_owner? && Pundit.policy(@user, rating.task).show?
  end
end
