# frozen_string_literal: true

require 'omniauth'
require 'omniauth-saml'
require 'ruby-saml'

module OmniAuth
  module Strategies
    class Bird < OmniAuth::Strategies::AbstractSaml
      if Settings.omniauth.bird.enable
        # Use the metadata received from the Identity Provider for initial configuration
        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
        idp_metadata = idp_metadata_parser.parse_remote_to_hash(Settings.omniauth.bird.metadata_url)
        configure idp_metadata

        # Our Service Provider has some configuration options
        option :certificate, File.read(Settings.omniauth.bird.certificate)
        option :private_key, File.read(Settings.omniauth.bird.private_key)
      end
    end
  end
end

OmniAuth.config.add_camelization 'bird', 'BIRD'
