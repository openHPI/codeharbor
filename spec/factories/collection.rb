FactoryGirl.define do
  factory :collection do
    title 'Some Collection'
    user {FactoryGirl.create(:user)}
    exercises {[FactoryGirl.create(:simple_exercise), FactoryGirl.create(:simple_exercise)]}
  end
end