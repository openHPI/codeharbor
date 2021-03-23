# frozen_string_literal: true

Ransack.configure do |c|
  c.sanitize_custom_scope_booleans = false # the sanitation broke scopes if a "1" was submitted
  c.search_key = :search
end
