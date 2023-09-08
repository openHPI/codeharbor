# frozen_string_literal: true

require 'omniauth'
require 'omniauth-saml'
require 'ruby-saml'

module OmniAuth
  module Strategies
    class SamlTestId < OmniAuth::Strategies::AbstractSaml
      if Settings.omniauth.samltestid.enable
        # Use the metadata received from the Identity Provider for initial configuration
        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
        idp_metadata = idp_metadata_parser.parse_remote_to_hash(Settings.omniauth.samltestid.metadata_url)
        configure idp_metadata

        # Our Service Provider has some configuration options
        option :idp_sso_service_url, 'https://samltest.id/idp/profile/SAML2/Redirect/SSO'
        option :idp_sso_service_binding, 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'
        option :certificate, File.read(Settings.omniauth.samltestid.certificate)
        option :private_key, File.read(Settings.omniauth.samltestid.private_key)

        # Don't forget to upload the metadata to use this test service:
        # Copy the XML from http://localhost:7500/users/auth/samltestid/metadata
        # to the metadata upload at https://samltest.id/upload.php
        #
        # You may then use the SSO & SLO service for testing purposes
        # If you want to test an IdP-initiated SLO, head over
        # to the advanced options of https://samltest.id/start-idp-test/
      end
    end
  end
end

OmniAuth.config.add_camelization 'samltestid', 'SAML Test ID'
