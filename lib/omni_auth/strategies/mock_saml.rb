# frozen_string_literal: true

require 'omniauth'
require 'omniauth-saml'
require 'ruby-saml'

module OmniAuth
  module Strategies
    class MockSaml < OmniAuth::Strategies::AbstractSaml
      if Settings.omniauth.mocksaml.enable
        # Use the metadata received from the Identity Provider for initial configuration
        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
        idp_metadata = idp_metadata_parser.parse_remote_to_hash(Settings.omniauth.mocksaml.metadata_url, true, desired_bindings)
        configure idp_metadata

        # The Mock SAML provider does not support the SLO service.

        # Further, the Mock SAML provider does neither support nor enforce metadata upload.
        # Hence, we don't need to configure the metadata endpoint nor certificates.

        info do
          {
            email: @attributes['email'],
            name: "#{@attributes['firstName']} #{@attributes['lastName']}",
            # For the Mock SAML provider, the login name is usually provided as the first and last name.
            first_name: @attributes['firstName'],
            last_name: @attributes['lastName'],
            display_name: @attributes['firstName'],
          }
        end

        uid { @attributes['id'] || @name_id }
      end
    end
  end
end

OmniAuth.config.add_camelization 'mocksaml', 'Mock SAML'
