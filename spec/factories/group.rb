# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Gruppe #{n}" }
    description { 'Lorem ipsum Bacon Soda.' }
    group_memberships { [build(:group_membership, :with_admin), build(:group_membership)] }
  end
end
