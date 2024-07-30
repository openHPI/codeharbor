# frozen_string_literal: true

namespace :nbp do
  desc 'Pushes all tasks to the NBP for an initial sync'
  task push_all: :environment do
    NbpSyncAllJob.perform_later
  end
end
