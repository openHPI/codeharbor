# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'seeds' do # rubocop:disable RSpec/DescribeClass
  subject(:seed) { Rake::Task['db:seed'].invoke }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    # We need to migrate the test database before seeding
    # Otherwise, Rails 7.1+ will throw an `NoMethodError`: `pending_migrations.any?`
    # See ActiveRecord gem, file `lib/active_record/railties/databases.rake`
    Rake::Task['db:migrate'].invoke

    # We want to execute the seeds for the dev environment against the test database
    # rubocop:disable Rails/Inquiry
    allow(Rails).to receive(:env) { 'development'.inquiry }
    # rubocop:enable Rails/Inquiry
    allow(ActiveRecord::Base).to receive(:establish_connection).and_call_original
    allow(ActiveRecord::Base).to receive(:establish_connection).with(:development) {
      ActiveRecord::Base.establish_connection(:test)
    }
  end

  describe 'execute db:seed', cleaning_strategy: :truncation do
    it 'collects the test results' do
      expect { seed }.not_to raise_error
    end
  end
end
