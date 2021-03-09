# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    title { 'Some Collection' }
    users { [build(:user)] }
    # exercises { [build(:simple_exercise), build(:simple_exercise)] }
  end
end
