# frozen_string_literal: true

module Nbp
  class SettingsError < StandardError; end
  class ConnectorError < StandardError; end

  class PushConnector
    include Singleton

    def initialize
      super
      create_source! unless source_exists?
    end

    def self.enabled?
      Settings.nbp&.push_connector&.enable || false
    end

    def push_lom!(xml)
      response = api_conn.put("/push-connector/api/lom-v2/#{settings.source.slug}") do |req|
        req.body = {metadata: xml}.to_json
      end
      raise_connector_error('Could not push task LOM', response) unless success_status?(response.status)
    end

    def delete_task!(task_uuid)
      response = api_conn.delete("/push-connector/api/course/#{settings.source.slug}/#{task_uuid}")
      raise_connector_error('Could delete task', response) unless success_status?(response.status) || response.status == 404
    end

    def source_exists?
      response = api_conn.get("/datenraum/api/core/sources/slug/#{settings.source.slug}")
      if response.status == 200
        true
      elsif response.status == 404
        false
      else
        raise_connector_error('Could not determine if source exists', response)
      end
    end

    def create_source!
      response = api_conn.post('/datenraum/api/core/sources') do |req|
        req.body = settings.source.to_json
      end
      raise_connector_error('Failed to create source', response) unless success_status?(response.status)
    end

    def token
      if @token.present? && @token_expiration > 10.seconds.from_now
        @token
      else
        update_token
      end
    end

    def update_token
      response = Faraday.post(settings.token_path, auth)
      result = JSON.parse(response.body)

      if success_status?(response.status)
        @token_expiration = Time.zone.now + result['expires_in']
        @token = result['access_token']
      else
        raise_connector_error('Failed to get fresh access token', response)
      end
    end

    def auth
      {
        grant_type: 'client_credentials',
        client_id: settings.client_id,
        client_secret: settings.client_secret,
      }
    end

    def api_conn
      Faraday.new(url: settings.api_host, headers:)
    end

    def settings
      return @connector_settings if @connector_settings

      check_settings!
      @connector_settings = Settings.nbp&.push_connector
    end

    def check_settings! # rubocop:disable Metrics/AbcSize
      settings_hash = Settings.nbp&.push_connector.to_h

      if PushConnector.enabled?
        missing_keys = %i[client_id client_secret token_path api_host source] - settings_hash.keys
        raise SettingsError.new("Nbp::PushConnector is missing some settings: #{missing_keys}") if missing_keys.any?

        missing_source_keys = %i[organization name slug] - settings_hash[:source].keys
        raise SettingsError.new("Nbp::PushConnector source is missing some settings: #{missing_source_keys}") if missing_source_keys.any?
      else
        raise SettingsError.new('Nbp::PushConnector is disabled but got accessed')
      end
    end

    def success_status?(status_code)
      (200..299).cover?(status_code)
    end

    def raise_connector_error(message, faraday_response)
      raise ConnectorError.new("#{message} (code #{faraday_response.status}). Response was: '#{faraday_response.body}'")
    end

    def headers
      {authorization: "Bearer #{token}", 'content-type': 'application/json', accept: 'application/json'}
    end
  end
end
