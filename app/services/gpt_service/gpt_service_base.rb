# frozen_string_literal: true

module GptService
  class GptServiceBase < ServiceBase
    def new_client!(access_token)
      raise Gpt::Error::InvalidApiKey if access_token.blank?

      OpenAI::Client.new(access_token:)
    end

    private

    def wrap_api_error!
      yield
    rescue Faraday::UnauthorizedError, OpenAI::Error => e
      raise Gpt::Error::InvalidApiKey.new("Could not authenticate with OpenAI: #{e.message}")
    rescue Faraday::Error => e
      raise Gpt::Error::InternalServerError.new("Could not communicate with OpenAI: #{e.inspect}")
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, SocketError, EOFError => e
      raise Gpt::Error.new(e)
    end
  end
end
