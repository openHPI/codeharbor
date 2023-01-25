# frozen_string_literal: true

FactoryBot.define do
  factory :group_membership do
    user { build(:user) }
    role { GroupMembership.roles[:member] }

    trait :with_admin do
      role { GroupMembership.roles[:admin] }
    end
    trait :with_applicant do
      role { GroupMembership.roles[:applicant] }
    end

    trait :with_group do
      group { build(:group) }
    end
  end
end
