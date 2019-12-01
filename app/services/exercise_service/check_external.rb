# frozen_string_literal: true

module ExerciseService
  class CheckExternal < ServiceBase
    def initialize(uuid:, account_link:)
      @uuid = uuid
      @account_link = account_link
    end

    def execute
      response = connection.post do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = 'Bearer ' + @account_link.api_key
        req.body = {uuid: @uuid}.to_json
      end
      response_hash = JSON.parse(response.body, symbolize_names: true)

      {error: false}.merge(response_hash.slice(:message, :exercise_found, :update_right))
    rescue Faraday::Error, JSON::ParserError
      {error: true, message: I18n.t('exercises.export_exercise.error')}
    end

    private

    def connection
      Faraday.new(url: @account_link.check_uuid_url) do |faraday|
        faraday.options[:open_timeout] = 5
        faraday.options[:timeout] = 5

        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
