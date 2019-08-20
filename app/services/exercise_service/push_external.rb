# frozen_string_literal: true

module ExerciseService
  class PushExternal < ServiceBase
    def initialize(zip:, account_link:)
      @zip = zip
      @account_link = account_link
    end

    def execute
      oauth2_client = OAuth2::Client.new(@account_link.client_id, @account_link.client_secret, site: @account_link.push_url)
      oauth2_token = @account_link[:oauth2_token]
      token = OAuth2::AccessToken.from_hash(oauth2_client, access_token: oauth2_token)
      body = @zip.string
      begin
        token.post(
          @account_link.push_url,
          body: body,
          headers: {'Content-Type' => 'application/zip', 'Content-Length' => body.length.to_s, 'Accept' => 'application/json'}
        )
        return nil
      rescue StandardError => e
        return e
      end
    end
  end
end
