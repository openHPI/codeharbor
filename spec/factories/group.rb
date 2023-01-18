# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Gruppe #{n}" }
    description { 'Lorem ipsum Bacon Soda.' }
    users { [create(:user), create(:user)] }

    # Special create handler is necessary, because the groupify gem doesn't allow assignment of members, when group is not saved yet.
    # This breaks a validation. This is based on Group.create_with_admin
    to_create do |group|
      group.save(validate: false)
      group_memberships.first.admin!
      group.validate!
    end
  end
end
