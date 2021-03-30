# frozen_string_literal: true

FactoryBot.define do
  factory :task_file do
    name { 'name' }

    trait :with_task do
      fileable { build(:task) }
    end

    trait :with_test do
      fileable { build(:test) }
    end

    trait :exportable do
      internal_description { 'internal_description' }
      usage_by_lms { 'display' }
      used_by_grader { true }
      visible { 'yes' }
    end

    trait(:with_text_attachment) do
      name { 'text' }
      content {}
      # attachment { Rack::Test::UploadedFile.new('spec/fixtures/files/example-filename.txt', 'text/plain') }
      after(:build) do |task_file|
        task_file.attachment.attach(io: File.open('spec/fixtures/files/example-filename.txt'),
                                    filename: 'example-filename.txt',
                                    content_type: 'text/plain')
      end
    end

    trait(:with_attachment) do
      name { 'image' }
      content {}
      after(:build) do |exercise_file|
        exercise_file.attachment.attach(io: File.open('spec/fixtures/files/red.bmp'), filename: 'red.bmp', content_type: 'image/bmp')
      end
    end
  end
end
