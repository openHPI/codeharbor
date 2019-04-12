FactoryBot.define do
  factory :collection do
    title { 'Some Collection' }
    users {[FactoryBot.create(:user)]}
    exercises {[FactoryBot.create(:simple_exercise), FactoryBot.create(:simple_exercise)]}
  end
end
