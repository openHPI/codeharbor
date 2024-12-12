# frozen_string_literal: true

require 'omniauth'
require 'omniauth-saml'
require 'ruby-saml'

module OmniAuth
  module Strategies
    class AbstractSaml < OmniAuth::Strategies::SAML
      option :attribute_service_name, 'CodeHarbor'

      # We don't request any specific attributes (statements) to get all automatically.
      option :request_attributes, {}
      option :attribute_statements, {}

      # We want to specify some security options ourselves
      option :security, {
        digest_method: XMLSecurity::Document::SHA512,
        signature_method: XMLSecurity::Document::RSA_SHA512,
        metadata_signed: true, # Enable signature on Metadata
        authn_requests_signed: true, # Enable signature on AuthNRequest
        logout_requests_signed: true, # Enable signature on Logout Request
        logout_responses_signed: true, # Enable signature on Logout Response
        want_assertions_signed: true, # Require the IdP to sign its SAML Assertions
        want_assertions_encrypted: true, # Invalidate SAML messages without an EncryptedAssertion
      }

      # During the request phase, we store the ID of the current user in the `request.params`.
      # It is passed through via SAML's standard `RelayState` parameter, so it will be preserved and can be used in the
      # callback phase.
      option :idp_sso_service_url_runtime_params, {
        relay_state: 'RelayState',
      }

      # This Lambda is responsible for terminating the session and will
      # only be used for identity-provider-initiated logout requests
      option :idp_slo_session_destroy, proc {|env, session|
        if Rails.env.development?
          # For development purposes, we want to assume a secure connection behind an TLS-terminating proxy.
          # If this option is not set, our session cookie is not sent by Rack (due to the `secure` flag)
          env['HTTP_X_FORWARDED_PROTO'] = 'https'
        end

        # We logout the active user if possible. Probably, the cookie is not included
        # in the request (due to a cross-origin request) and the following line is a no-op.
        env['warden'].logout
        # Delete all information from the current session
        session.clear

        # We want to ensure that the new cookie (with an empty session) is set by the client.
        # Doing so will definitely overwrite an existing session in the browser
        # Our mechanism will only work through HTTPS and with the following two options
        env['rack.session'].options[:secure] = true
        env['rack.session'].options[:same_site] = :none
      }

      # The attributes used in the `info` and `uid` hash below might be overwritten
      # by provider-specific mappings if required. We chose to include a suitable default mapping
      # here that should fit most providers. It is in accordance with the mappings of the DFN:
      # https://doku.tid.dfn.de/de:common_attributes

      info do
        {
          email: @attributes['urn:oid:0.9.2342.19200300.100.1.3'],
          name: @attributes['urn:oid:2.5.4.3'],
          first_name: @attributes['urn:oid:2.5.4.42'],
          last_name: @attributes['urn:oid:2.5.4.4'],
          display_name: @attributes['urn:oid:2.16.840.1.113730.3.1.241'],
        }
      end

      uid { @name_id || @attributes['urn:oid:0.9.2342.19200300.100.1.1'] }

      def with_settings # rubocop:disable Metrics/AbcSize
        # Get persistent IDs to recognize returning users
        options[:name_identifier_format] = 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'

        options[:sp_entity_id] ||= sso_path
        options[:single_logout_service_url] ||= slo_path
        options[:slo_default_relay_state] ||= full_host

        if on_request_path? && current_user
          # Store the ID of the current user in the SAML RelayState if a user is logged in, so that it can be accessed
          # for requesting the current user in the callback phase and to add the new identity to the existing account.
          request.params['relay_state'] = NonceStore.add current_user.id
        end
        super
      end

      def sso_path
        "#{full_host}#{script_name}#{request_path}"
      end

      def slo_path
        # This path is defined and handled by the `omniauth-saml` gem
        "#{full_host}#{script_name}#{request_path}/slo"
      end

      def current_user
        env['warden'].user
      end

      class << self
        def desired_bindings
          {
            sso_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
            slo_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
          }
        end
      end
    end
  end
end
