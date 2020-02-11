# frozen_string_literal: true

class GroupMembership < ApplicationRecord
  groupify :group_membership

  validates_uniqueness_of :member_id, scope: %i[group_id group_type membership_type]
end
