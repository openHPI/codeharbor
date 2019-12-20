# frozen_string_literal: true

FactoryBot.define do
  factory :exercise_relation do
    origin { build(:simple_exercise) }
    clone { build(:simple_exercise) }
    relation { build(:relation) }
  end
end
