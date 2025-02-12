# frozen_string_literal: true

class TaskService
  class CheckExternal < TaskService
    def initialize(uuid:, account_link:)
      super()
      @uuid = uuid
      @account_link = account_link
    end

    def execute
      body = {uuid: @uuid}.to_json
      response = self.class.connection.post(@account_link.check_uuid_url) {|request| request_parameters(request, body) }
      response_hash = JSON.parse(response.body, symbolize_names: true).slice(:uuid_found, :update_right)

      {error: false, message: message(response_hash)}.merge(response_hash)
    rescue Faraday::Error, JSON::ParserError
      {error: true, message: I18n.t('common.errors.generic')}
    end

    private

    def request_parameters(request, body)
      request.tap do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{@account_link.api_key}"
        req.body = body
      end
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
  end
end
