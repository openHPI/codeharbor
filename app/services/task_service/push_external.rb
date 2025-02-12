# frozen_string_literal: true

class TaskService
  class PushExternal < TaskService
    def initialize(zip:, account_link:)
      super()
      @zip = zip
      @account_link = account_link
    end

    def execute
      body = @zip.string
      begin
        response = self.class.connection.post(@account_link.push_url) {|request| request_parameters(request, body) }
        response.success? ? nil : response.body
      rescue StandardError => e
        e
      end
    end

    private

    def request_parameters(request, body)
      request.tap do |req|
        req.headers['Content-Type'] = 'application/zip'
        req.headers['Content-Length'] = body.length.to_s
        req.headers['Authorization'] = "Bearer #{@account_link.api_key}"
        req.body = body
      end
    end
  end
end
