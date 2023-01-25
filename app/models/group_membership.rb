# frozen_string_literal: true

class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :user_id, uniqueness: {scope: :group_id}
  validates :role, presence: true

  enum role: {applicant: 0, member: 1, admin: 2}
end
