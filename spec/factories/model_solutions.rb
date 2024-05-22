# frozen_string_literal: true

FactoryBot.define do
  factory :model_solution do
    task
    sequence(:xml_id) {|n| "ms_#{n}" }
  end

  trait :with_content do
    description { 'description' }
    internal_description { 'internal_description' }

    files { [build(:task_file, :exportable)] }
  end
end
