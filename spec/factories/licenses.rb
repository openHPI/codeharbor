# frozen_string_literal: true

FactoryBot.define do
  factory :license do
    sequence(:name) {|n| "license#{n}"}
    link { 'Link' }
  end
end
