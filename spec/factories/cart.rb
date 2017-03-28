FactoryGirl.define do
  factory :cart do
    user {FactoryGirl.create(:user)}
    exercises {[FactoryGirl.create(:simple_exercise), FactoryGirl.create(:simple_exercise)]}
  end

end