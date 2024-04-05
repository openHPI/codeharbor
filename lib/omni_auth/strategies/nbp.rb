# frozen_string_literal: true

require 'omniauth'
require 'omniauth-saml'
require 'ruby-saml'

module OmniAuth
  module Strategies
    class Nbp < OmniAuth::Strategies::AbstractSaml
      if Settings.omniauth.nbp.enable
        # Use the metadata received from the Identity Provider for initial configuration
        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
        idp_metadata = idp_metadata_parser.parse_remote_to_hash(Settings.omniauth.nbp.metadata_url, true, desired_bindings)
        configure idp_metadata

        # Our Service Provider has some configuration options
        option :certificate, File.read(Settings.omniauth.nbp.certificate)
        option :private_key, File.read(Settings.omniauth.nbp.private_key)
      end
    end
  end
end

OmniAuth.config.add_camelization 'nbp', 'Mein Bildungsraum'
