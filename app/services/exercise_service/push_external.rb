# frozen_string_literal: true

module ExerciseService
  class PushExternal < ServiceBase
    def initialize(zip:, account_link:)
      @zip = zip
      @account_link = account_link
    end

    def execute
      body = @zip.string
      begin
        conn = Faraday.new(url: @account_link.push_url) do |faraday|
          faraday.adapter Faraday.default_adapter
        end

        conn.post do |req|
          req.headers['Content-Type'] = 'application/zip'
          req.headers['Content-Length'] = body.length.to_s
          req.headers['Authorization'] = 'Bearer ' + @account_link.api_key
          req.body = body
        end
        return nil
      rescue StandardError => e
        return e
      end
    end
  end
end
