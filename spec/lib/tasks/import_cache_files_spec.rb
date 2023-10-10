# frozen_string_literal: true

require 'rails_helper'
Rails.application.load_tasks
# rubocop:disable RSpec/DescribeClass
RSpec.describe 'import_cache_files:cleanup' do
  before do
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
# rubocop:enable RSpec/DescribeClass
