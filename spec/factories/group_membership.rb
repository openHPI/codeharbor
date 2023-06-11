# frozen_string_literal: true

FactoryBot.define do
  factory :group_membership do
    user
    role { :confirmed_member }

    trait :with_admin do
      role { :admin }
    end
    trait :with_applicant do
      role { :applicant }
    end

    trait :with_group do
      group
    end
  end
end
