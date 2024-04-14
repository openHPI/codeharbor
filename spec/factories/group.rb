# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:name) {|n| "Gruppe #{n}" }
    description { 'Lorem ipsum Bacon Soda.' }
    # We pass `group: nil` to avoid circular references. It will still associate the group_memberships with the group.
    group_memberships { [build(:group_membership, :with_admin, group: nil), build(:group_membership, group: nil)] }
  end
end
