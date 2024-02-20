# frozen_string_literal: true

FactoryBot.define do
  factory :task_contribution do
    suggestion { association :task, user:, parent_uuid: original_task.uuid }

    transient do
      user { association :user }
      original_task { association :task }
    end

    after(:build) do |task_contribution, context|
      task_contribution.base = context.original_task
    end
  end
end
