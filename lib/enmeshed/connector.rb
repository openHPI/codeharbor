# frozen_string_literal: true

module Enmeshed
  class ConnectorError < StandardError; end

  class Connector
    API_KEY = Settings.omniauth&.nbp&.enmeshed&.connector_api_key
    CONNECTOR_URL = Settings.omniauth&.nbp&.enmeshed&.connector_url
    DISPLAY_NAME = Settings.omniauth&.nbp&.enmeshed&.display_name

    @conn = nil
    @enmeshed_address = nil
    @display_name_id = nil

    def self.create_relationship_template(nbp_uid)
      new_template = parse_result(conn.post('/api/v2/RelationshipTemplates/Own') do |req|
        req.body = RelationshipTemplate.json(nbp_uid, display_name_attribute, display_name_id)
      end)

      Rails.logger.debug { "Enmeshed::ConnectorApi RelationshipTemplate created: #{new_template[:truncatedReference]}" }
      RelationshipTemplate.new(new_template[:truncatedReference])
    end

    def self.pending_relationship_for_nbp_uid(nbp_uid)
      relationships = parse_relationships(conn.get('/api/v2/Relationships') do |req|
        req.params['status'] = 'Pending'
      end).select(&:valid?)
      # We want to call valid? for all relationships because it internally rejects invalid relationships

      relationships.find {|rel| rel.nbp_uid == nbp_uid }
    end

    def self.respond_to_rel_change(relationship_id, change_id, action = 'Accept')
      response = conn.put("/api/v2/Relationships/#{relationship_id}/Changes/#{change_id}/#{action}") do |req|
        req.body = {content: {}}.to_json
      end
      Rails.logger.debug do
        "Enmeshed::ConnectorApi responded to RelationshipChange with: #{action}; connector response status is #{response.status}"
      end

      response.status == 200
    end

    def self.parse_result(response)
      json = JSON.parse(response.body).deep_symbolize_keys

      if json.include?(:error)
        raise ConnectorError.new(
          "Enmeshed connector response contained error: #{json[:error][:message]}. Full response was: #{response.body}"
        )
      end

      json[:result]
    rescue JSON::ParserError
      raise ConnectorError.new("Enmeshed connector response could not be parsed. Received: #{response.body}")
    end
    private_class_method :parse_result

    def self.parse_relationships(response)
      parse_result(response).map {|relationship_json| Relationship.new(relationship_json) }
    end
    private_class_method :parse_relationships

    def self.display_name_attribute
      {
        '@type': 'IdentityAttribute',
        owner: enmeshed_address,
        value: {
          '@type': 'DisplayName',
          value: DISPLAY_NAME,
        },
      }
    end
    private_class_method :display_name_attribute

    def self.conn
      @conn ||= init_conn
    end
    private_class_method :conn

    def self.init_conn
      if User.omniauth_providers.exclude?(:nbp) || CONNECTOR_URL.nil? || API_KEY.nil? || DISPLAY_NAME.nil?
        raise ConnectorError.new('NBP provider or enmeshed connector not configured as expected')
      end

      Faraday.new(CONNECTOR_URL, headers:)
    end
    private_class_method :init_conn

    def self.enmeshed_address
      return @enmeshed_address if @enmeshed_address.present?

      identity = parse_result conn.get('/api/v2/Account/IdentityInfo')
      @enmeshed_address = identity[:address]
    end
    private_class_method :enmeshed_address

    def self.display_name_id
      @display_name_id ||= existing_display_name_attr || create_display_name_attr
    end
    private_class_method :display_name_id

    def self.create_display_name_attr
      parse_result(conn.post('/api/v2/Attributes') do |req|
        req.body = {content: display_name_attribute}.to_json
      end)[:id]
    end
    private_class_method :create_display_name_attr

    def self.existing_display_name_attr
      parse_result(conn.get('/api/v2/Attributes') do |req|
        req.params['content.@type'] = 'IdentityAttribute'
        req.params['content.owner'] = enmeshed_address
        req.params['content.value.@type'] = 'DisplayName'
      end).find {|attr| attr.dig(:content, :value, :value) == DISPLAY_NAME }&.dig(:id)
    end
    private_class_method :existing_display_name_attr

    def self.headers
      {'X-API-KEY': API_KEY, 'content-type': 'application/json', accept: 'application/json'}
    end
    private_class_method :headers
  end
end
