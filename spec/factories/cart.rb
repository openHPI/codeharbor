# frozen_string_literal: true

FactoryBot.define do
  factory :cart do
    user { FactoryBot.create(:user) }
    exercises { [FactoryBot.create(:simple_exercise), FactoryBot.create(:simple_exercise)] }
  end
end
