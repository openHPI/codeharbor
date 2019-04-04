FactoryBot.define do
  factory :file_type, class: 'FileType' do
    name { "Java" }
    file_extension { ".java" }
  end

  factory :java_file_type, class: 'FileType' do
    name { "Java" }
    file_extension { ".java" }
  end

  factory :txt_file_type, class: 'FileType' do
    name { "Plain Text" }
    file_extension { ".txt" }
  end
end
