# frozen_string_literal: true

FactoryBot.define do
  factory :testing_framework, aliases: [:junit_testing_framework] do
    name { 'JUnit' }
    version { '4' }
  end
end
