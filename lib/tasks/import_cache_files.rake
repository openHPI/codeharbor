# frozen_string_literal: true

namespace :import_cache_files do
  desc 'deletes ImportFileCaches older than 24 hours'
  task cleanup: :environment do
    old_files = ImportFileCache.where('created_at < ?', 1.day.ago)
    puts "there are #{old_files.count} old cached files to be deleted"
    old_files.destroy_all
    puts 'deletion complete'
  end
end
