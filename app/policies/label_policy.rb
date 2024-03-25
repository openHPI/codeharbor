# frozen_string_literal: true

class LabelPolicy < ApplicationPolicy
  def search?
    everyone
  end

  %i[index? merge? update? destroy?].each do |action|
    define_method(action) { admin? || @user.id == 72 }
  end
end
