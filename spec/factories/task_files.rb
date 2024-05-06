# frozen_string_literal: true

FactoryBot.define do
  factory :task_file do
    name { 'name' }
    fileable factory: :task
    sequence(:xml_id, &:to_s)

    trait :with_test do
      fileable factory: :test
    end

    trait :exportable do
      internal_description { 'internal_description' }
      content { 'content' }
      path { '' }
      usage_by_lms { 'display' }
      used_by_grader { true }
      visible { 'yes' }
    end

    trait :with_text_attachment do
      name { 'text' }
      content {}
      use_attached_file { 'true' }
      after(:build) do |task_file|
        task_file.attachment.attach(io: File.open('spec/fixtures/files/example-filename.txt'),
          filename: 'example-filename.txt',
          content_type: 'text/plain')
      end
    end

    trait :with_attachment do
      name { 'image' }
      content {}
      use_attached_file { 'true' }
      after(:build) do |file|
        file.attachment.attach(io: File.open('spec/fixtures/files/red.bmp'), filename: 'red.bmp', content_type: 'image/bmp')
      end
    end
  end
end
