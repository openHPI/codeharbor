# frozen_string_literal: true

OpenAI.configure do |config|
  next unless Settings.open_ai

  config.access_token = Settings.open_ai.access_token
end
