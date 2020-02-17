# frozen_string_literal: true

FactoryBot.define do
  factory :group_membership do
    member { create(:user) }
    group { create(:group) }
    membership_type { 'member' }
  end
end
