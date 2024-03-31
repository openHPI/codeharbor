# frozen_string_literal: true

module Enmeshed
  class RelationshipTemplate
    def initialize(truncated_reference)
      @truncated_reference = truncated_reference
    end

    attr_reader :truncated_reference

    def url
      "nmshd://tr##{@truncated_reference}"
    end

    def app_store_link
      Settings.omniauth.nbp.enmeshed.app_store_link
    end

    def play_store_link
      Settings.omniauth.nbp.enmeshed.play_store_link
    end

    def qr_code
      RQRCode::QRCode.new(url).as_png(border_modules: 0)
    end

    def qr_code_path
      Rails.application.routes.url_helpers.nbp_wallet_qr_code_users_path(truncated_reference:)
    end

    def validity_period
      Enmeshed::Connector::TEMPLATE_VALIDITY_PERIOD.seconds
    end
  end
end
