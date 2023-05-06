# frozen_string_literal: true

FactoryBot.define do
  factory :task_labels do
    task { build(:task) }
    label { build(:label) }
  end
end
