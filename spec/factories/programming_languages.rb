# frozen_string_literal: true

FactoryBot.define do
  factory :programming_language do
    trait :ruby do
      language { 'Ruby' }
      version { '3.0.0' }
      file_extension { '.rb' }
    end

    trait :python do
      language { 'Python' }
      version { '3.8' }
      file_extension { '.py' }
    end
  end
end
