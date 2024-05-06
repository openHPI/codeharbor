# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'import_cache_files:cleanup' do # rubocop:disable RSpec/DescribeClass
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    allow($stdout).to receive(:write) # supress output

    create(:import_file_cache, created_at: DateTime.now - 1.day)
    create(:import_file_cache, created_at: DateTime.now - 1.week)
    create(:import_file_cache, created_at: DateTime.now - 1.hour)
  end

  let(:task) { Rake::Task['import_cache_files:cleanup'].invoke }

  it 'deletes two files' do
    expect { task }.to change(ImportFileCache, :count).by(-2)
  end
end
