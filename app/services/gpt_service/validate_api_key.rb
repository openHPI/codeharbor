# frozen_string_literal: true

module GptService
  class ValidateApiKey < GptServiceBase
    def initialize(openai_api_key:)
      super()

      @client = new_client! openai_api_key
    end

    def execute
      validate!
    end

    def validate!
      wrap_api_error! do
        response = @client.models.list
        raise Gpt::Error::InvalidApiKey unless response['data']
      end
    end
  end
end
