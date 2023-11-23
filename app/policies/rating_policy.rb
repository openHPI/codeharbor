# frozen_string_literal: true

class RatingPolicy < ApplicationPolicy
  def rating
    @record
  end

  def new?
    everyone
  end

  def create?
    record_owner? && Pundit.policy(@user, rating.task).show?
  end
end
