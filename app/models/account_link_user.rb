# frozen_string_literal: true

class AccountLinkUser < ApplicationRecord
  validates :user, uniqueness: {scope: :account_link}

  belongs_to :account_link
  belongs_to :user
end
