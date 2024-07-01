# frozen_string_literal: true

class DestroyDanglingUserIdentities < ActiveRecord::Migration[7.1]
  class User < ApplicationRecord
    has_many :identities, class_name: 'UserIdentity'
  end

  class UserIdentity < ApplicationRecord
    belongs_to :user
  end

  def up
    UserIdentity.joins(:user).where(user: {deleted: true}).destroy_all
  end
end
