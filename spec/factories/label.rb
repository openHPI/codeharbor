FactoryBot.define do
  factory :label do
    sequence(:name) { |n| "Test Label #{n}" }
  end
end
