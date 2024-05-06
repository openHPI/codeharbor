# frozen_string_literal: true

module TaskService
  class CheckExternal < ServiceBase
    def initialize(uuid:, account_link:)
      super()
      @uuid = uuid
      @account_link = account_link
    end

    def execute
      response = connection.post do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = authorization_header
        req.body = {uuid: @uuid}.to_json
      end
      response_hash = JSON.parse(response.body, symbolize_names: true).slice(:uuid_found, :update_right)

      {error: false, message: message(response_hash)}.merge(response_hash)
    rescue Faraday::Error, JSON::ParserError
      {error: true, message: I18n.t('common.errors.generic')}
    end

    private

    def authorization_header
      "Bearer #{@account_link.api_key}"
    end

    def message(response_hash)
      if response_hash[:uuid_found]
        if response_hash[:update_right]
          I18n.t('tasks.task_service.check_external.task_found')
        else
          I18n.t('tasks.task_service.check_external.task_found_no_right')
        end
      else
        I18n.t('tasks.task_service.check_external.no_task')
      end
    end

    def connection
      Faraday.new(url: @account_link.check_uuid_url) do |faraday|
        faraday.options[:open_timeout] = 5
        faraday.options[:timeout] = 5

        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
