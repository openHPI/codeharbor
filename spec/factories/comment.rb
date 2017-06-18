FactoryGirl.define do
  factory :comment do
    text 'A good comment'
    exercise {FactoryGirl.create(:simple_exercise)}
    user {FactoryGirl.create(:user)}
  end
end