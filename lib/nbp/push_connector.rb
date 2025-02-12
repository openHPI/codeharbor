# frozen_string_literal: true

require 'singleton'
require 'concurrent'

module Nbp
  class PushConnector
    include Singleton

    class Error < StandardError; end
    class SettingsError < Error; end
    class ServerError < Error; end

    def initialize
      super
      @token = Concurrent::ThreadLocalVar.new
      @token_expiration = Concurrent::ThreadLocalVar.new

      create_source! unless source_exists?
    end

    def self.enabled?
      return @enabled if defined? @enabled

      @enabled = Settings.nbp&.push_connector&.enable || false
    end

    def push_lom!(xml)
      response = api_conn.put("/push-connector/api/lom-v2/#{source_slug}") do |req|
        req.body = {metadata: xml}.to_json
      end
      raise ServerError if response.status == 500

      raise_connector_error('Could not push task LOM', response) unless response.success?
    end

    def delete_task!(task_uuid)
      response = api_conn.delete("/push-connector/api/course/#{source_slug}/#{task_uuid}")
      raise ServerError if response.status == 500

      raise_connector_error('Could not delete task', response) unless response.success? || response.status == 404
    end

    def process_uploaded_task_uuids(&)
      offset = 0
      until (uuids = get_uploaded_task_uuids(offset)).empty?
        offset += uuids.length
        uuids.map(&)
      end
    end

    def source_exists?
      response = api_conn.get("/datenraum/api/core/sources/slug/#{source_slug}")
      if response.status == 200
        true
      elsif response.status == 404
        false
      else
        raise_connector_error('Could not determine if source exists', response)
      end
    end

    private

    def get_uploaded_task_uuids(offset, limit = 100) # rubocop:disable Metrics/AbcSize
      raise Error('The NBP API does not accept limits over 100') if limit > 100

      response = api_conn.get('/datenraum/api/core/nodes') do |req|
        req.params[:sourceSlug] = source_slug
        req.params[:offset] = offset
        req.params[:limit] = limit
      end
      raise ServerError if response.status == 500

      raise_connector_error('Could query existing tasks', response) unless response.success?

      nodes = JSON.parse(response.body).deep_symbolize_keys.dig(:_embedded, :nodes)
      raise_connector_error('Nodes response did not contain nodes list', response) if nodes.nil?

      nodes.pluck(:externalId).compact
    end

    def create_source!
      response = api_conn.post('/datenraum/api/core/sources') do |req|
        req.body = settings.source.to_json
      end
      raise_connector_error('Failed to create source', response) unless response.success?
    end

    def token
      if @token.value.present? && @token_expiration.value > 10.seconds.from_now
        @token.value
      else
        update_token
      end
    end

    def update_token
      response = Faraday.post(settings.token_path, auth)
      result = JSON.parse(response.body)

      if response.success?
        @token_expiration.value = Time.zone.now + result['expires_in']
        @token.value = result['access_token']
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
      # Refresh headers (incl. the dynamic API token) for each request
      return @api_conn.tap {|req| req.headers = headers } if @api_conn

      @api_conn ||= Faraday.new(url: settings.api_host, headers:) do |faraday|
        faraday.options[:open_timeout] = 5
        faraday.options[:timeout] = 5

        faraday.adapter :net_http_persistent
      end
    end

    def source_slug
      settings.source.slug
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

    def raise_connector_error(message, faraday_response)
      raise Error.new("#{message} (code #{faraday_response.status}). Response was: '#{faraday_response.body}'")
    end

    def headers
      {authorization: "Bearer #{token}", 'content-type': 'application/json', accept: 'application/json'}
    end
  end
end
