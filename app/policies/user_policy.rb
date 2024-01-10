# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def accessed_user
    @record
  end

  def current_user
    @user
  end

  def message?
    current_user != accessed_user
  end

  %i[show? update? edit? delete? manage_accountlinks? remove_account_link?].each do |action|
    define_method(action) { admin? || current_user == accessed_user }
  end
end
