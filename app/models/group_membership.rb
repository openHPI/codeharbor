# frozen_string_literal: true

class GroupMembership < ApplicationRecord
  groupify :group_membership

  validate :membership_unique
  scope :similars, lambda { |membership|
    where(membership.attributes.select { |key| key.in? %w[member_id member_type group_type group_id] })
      .where.not(id: membership.id)
  }

  private

  def membership_unique
    similar_memberships = GroupMembership.unscoped.similars(self)
    return unless similar_memberships.filter { |gm| membership_type.nil? ? gm.membership_type.nil? : !gm.membership_type.nil? }.any?

    errors.add(:base, 'cannot have multiple memberships')
  end
end
