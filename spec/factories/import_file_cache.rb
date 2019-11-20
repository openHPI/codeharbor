# frozen_string_literal: true

FactoryBot.define do
  factory :import_file_cache, class: 'ImportFileCache' do
    data {}
    user { build(:user) }
  end
end
