# frozen_string_literal: true

class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :user, uniqueness: {scope: :group}

  enum role: [:applicant, :member, :admin]
end
