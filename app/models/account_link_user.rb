# frozen_string_literal: true

class AccountLinkUser < ApplicationRecord
  belongs_to :account_link
  belongs_to :user
end
