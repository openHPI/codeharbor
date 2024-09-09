# frozen_string_literal: true

# Meta seed file that required depending on the Rails env different files from
# db/seeds/ Please put the seed in the best matching file
#
#   * all: Objects are needed in every environment (production, development)
#   * production: Objects are only needed for deployment
#   * development: Only needed for local development
#

# Disable seeding if there are already users in the database
return if User.any?

['all', Rails.env].each do |seed|
  seed_file = Rails.root.join("db/seeds/#{seed}.rb")
  if seed_file.exist?
    puts "*** Loading \"#{seed}\" seed data" # rubocop:disable Rails/Output
    load seed_file
  else
    puts "*** Skipping \"#{seed}\" seed data: \"#{seed_file}\" not found" # rubocop:disable Rails/Output
  end
end
