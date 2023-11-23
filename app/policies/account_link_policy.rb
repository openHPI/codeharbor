# frozen_string_literal: true

class AccountLinkPolicy < ApplicationPolicy
  def account_link
    @record
  end

  %i[create? new? update? edit? destroy? add_shared_user?].each do |action|
    define_method(action) { admin? || record_owner? }
  end

  %i[show? remove_shared_user?].each do |action|
    define_method(action) { admin? || record_owner? || account_link.shared_users.include?(@user) }
  end
end
