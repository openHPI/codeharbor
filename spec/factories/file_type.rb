# frozen_string_literal: true

FactoryBot.define do
  factory :file_type, class: 'FileType' do
    name { 'Java' }
    file_extension { '.java' }
  end

  factory :java_file_type, class: 'FileType' do
    name { 'Java' }
    file_extension { '.java' }
  end

  factory :txt_file_type, class: 'FileType' do
    name { 'Plain Text' }
    file_extension { '.txt' }
  end

  factory :bmp_file_type, class: 'FileType' do
    name { 'Bitmap' }
    file_extension { '.bmp' }
  end
end
