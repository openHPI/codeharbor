# frozen_string_literal: true

require 'omniauth'
require 'omniauth-saml'
require 'ruby-saml'

module OmniAuth
  module Strategies
    class AbstractSaml < OmniAuth::Strategies::SAML
      # We want to specify some security options ourselves
      option :security, {
        digest_method: XMLSecurity::Document::SHA512,
        signature_method: XMLSecurity::Document::RSA_SHA512,
        metadata_signed: true, # Enable signature on Metadata
        authn_requests_signed: true, # Enable signature on AuthNRequest
        logout_requests_signed: true, # Enable signature on Logout Request
        logout_responses_signed: true, # Enable signature on Logout Response
        want_assertions_signed: true, # Require the IdP to sign its SAML Assertions
        want_assertions_encrypted: true # Invalidate SAML messages without an EncryptedAssertion
      }

      # Our auto-login mechanism passes a desired redirect path (signed with a
      # secret to prevent tampering) to the request phase.
      # If we forward this via SAML's standard "RelayState" parameter, we will
      # get it back in the callback phase.
      # TODO: This parameter is not yet used in the app
      option :idp_sso_target_url_runtime_params, {
        redirect_path: 'RelayState'
      }

      # This Lambda is responsible for terminating the session and will
      # only be used for identity-provider-initiated logout requests
      option :idp_slo_session_destroy, (proc { |env, _session|
        if Rails.env.development?
          # For development purposes, we want to assume a secure connection behind an TLS-terminating proxy.
          # If this option is not set, our session cookie is not sent by Rack (due to the `secure` flag)
          env['HTTP_X_FORWARDED_PROTO'] = 'https'
        end

        # We logout the active user if possible. Probably, the cookie is not included
        # in the request (due to a cross-origin request) and the following line is a no-op.
        env['warden'].logout

        # We want to ensure that the new cookie (with an empty session) is set by the client.
        # Doing so will definitely overwrite an existing session in the browser
        # Our mechanism will only work through HTTPS and with the following two options
        env['rack.session'].options[:secure] = true
        env['rack.session'].options[:same_site] = :none
      })

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
          display_name: @attributes['urn:oid:2.16.840.1.113730.3.1.241']
        }
      end

      uid { @name_id || @attributes['urn:oid:0.9.2342.19200300.100.1.1'] }

      def with_settings
        # Get persistent IDs to recognize returning users
        options[:name_identifier_format] = 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'

        options[:sp_entity_id] ||= hostname
        options[:single_logout_service_url] ||= slo_path
        super
      end

      def hostname
        full_host + script_name
      end

      def slo_path
        # This path is defined and handled by the `omniauth-saml` gem
        "#{full_host}#{script_name}#{request_path}/slo"
      end

      def self.restore_deprecated_options
        # The `omniauth-saml` gem still uses some of these deprecated options and does not work correctly otherwise
        option :assertion_consumer_logout_service_url, default_options[:single_logout_service_url]
        option :assertion_consumer_logout_service_binding, default_options[:single_logout_service_binding]
        option :issuer, default_options[:sp_entity_id]
        option :idp_sso_target_url, default_options[:idp_sso_service_url]
        option :idp_slo_target_url, default_options[:idp_slo_service_url]
      end

      class << self
        def sign(url)
          Rails.application.message_verifier('saml').generate(url)
        end

        def try_verify(url)
          Rails.application.message_verifier('saml').verified(url)
        end
      end
    end
  end
end
