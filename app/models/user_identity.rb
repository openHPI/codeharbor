# frozen_string_literal: true

class UserIdentity < ApplicationRecord
  belongs_to :user

  validates :omniauth_provider, presence: true
  validates :provider_uid, presence: true, uniqueness: {scope: :omniauth_provider}
end
