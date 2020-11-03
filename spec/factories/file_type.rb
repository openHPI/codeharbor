# frozen_string_literal: true

FactoryBot.define do
  factory :file_type, class: 'FileType' do
    name { 'Java' }
    file_extension { '.java' }

    initialize_with do
      FileType.find_or_create_by(file_extension: file_extension) do |filetype|
        filetype.name = name
      end
    end

    factory :java_file_type, class: 'FileType' do
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
end
