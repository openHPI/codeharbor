# frozen_string_literal: true

FactoryBot.define do
  factory :junit_testing_framework, class: 'TestingFramework' do
    name { 'JUnit' }
    version { '4' }
  end
end
