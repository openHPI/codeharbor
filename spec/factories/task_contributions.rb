# frozen_string_literal: true

FactoryBot.define do
  factory :task_contribution do
    modifying_task { association :task, user:, parent_uuid: original_task.uuid }

    transient do
      user { association :user }
      original_task { association :task }
    end
  end
end
