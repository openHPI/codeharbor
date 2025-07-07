# frozen_string_literal: true

class TaskService
  class PushExternal < TaskService
    def initialize(zip:, account_link:)
      super()
      @zip = zip
      @account_link = account_link
    end

    def execute
      response = self.class.connection.post(@account_link.push_url) {|request| request_parameters(request, @zip.string) }
      return nil if response.success?
      return I18n.t('tasks.export_external_confirm.not_authorized', account_link: @account_link.name) if response.status == 401

      handle_error(message: response.body)
    rescue Faraday::ServerError => e
      handle_error(error: e, message: I18n.t('tasks.export_external_confirm.server_error', account_link: @account_link.name))
    rescue StandardError => e
      handle_error(error: e)
    end

    private

    def handle_error(message: nil, error: nil)
      Sentry.capture_exception(error) if error.present?
      ERB::Util.html_escape(message || error.to_s)
    end

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
