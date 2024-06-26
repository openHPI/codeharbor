# frozen_string_literal: true

FactoryBot.define do
  factory :task_contribution do
    suggestion { association :task, user:, parent_uuid: base.uuid }

    transient do
      user { association :user }
      base { association :task }
    end

    after(:build) do |task_contribution, context|
      task_contribution.base = context.base
    end
  end
end
