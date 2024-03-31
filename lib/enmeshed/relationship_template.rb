# frozen_string_literal: true

module Enmeshed
  class RelationshipTemplate
    # The app does not allow users to scan expired templates.
    # However, previously scanned and then expired templates can still be submitted,
    # resulting in the app silently doing nothing. CodeHarbor would still accept Relationships for expired templates if sent by the app.
    # To minimize the risk of a template expiring before submission, we set the validity to 12 hours.
    VALIDITY_PERIOD = 12.hours
    # These attributes are mandatory in the app and must be provided.
    # See https://enmeshed.eu/integrate/attribute-values for more attributes.
    REQUIRED_ATTRIBUTES = %w[GivenName Surname EMailAddress AffiliationRole].freeze

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

    def self.json(nbp_uid, display_name_attribute, display_name_id)
      {
        maxNumberOfAllocations: 1,
        expiresAt: VALIDITY_PERIOD.from_now,
        content: {
          metadata: {nbp_uid:},
          '@type': 'RelationshipTemplateContent',
          onNewRelationship: {
            '@type': 'Request',
            items: [
              {
                '@type': 'ShareAttributeRequestItem',
                mustBeAccepted: true,
                attribute: display_name_attribute,
                sourceAttributeId: display_name_id,
              },
            ] + required_attributes_template,
          },
        },
      }.to_json
    end

    def self.required_attributes_template
      REQUIRED_ATTRIBUTES.map do |attr|
        {
          '@type': 'ReadAttributeRequestItem',
          mustBeAccepted: true,
          query: {
            '@type': 'IdentityAttributeQuery',
            valueType: attr,
          },
        }
      end
    end
  end
end
