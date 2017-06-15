FactoryGirl.define do
  factory :group do
    sequence(:name) {|n| "Gruppe #{n}" }
    description 'Lorem ipsum Bacon Soda.'
    users { [FactoryGirl.create(:user, is_active: true), FactoryGirl.create(:user, is_active: true)] }
  end
end