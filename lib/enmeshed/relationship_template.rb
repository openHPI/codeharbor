# frozen_string_literal: true

module Enmeshed
  class RelationshipTemplate
    # The app does not allow users to scan expired templates.
    # However, previously scanned and then expired templates can still be submitted,
    # resulting in the app silently doing nothing. CodeHarbor would still accept Relationships for expired templates if sent by the app.
    # To minimize the risk of a template expiring before submission, we set the validity to 12 hours.
    VALIDITY_PERIOD = 12.hours
    # The display name of the service as shown in the enmeshed app.
    DISPLAY_NAME = Settings.omniauth&.nbp&.enmeshed&.display_name
    # These attributes are mandatory in the app and must be provided.
    # See https://enmeshed.eu/integrate/attribute-values for more attributes.
    REQUIRED_ATTRIBUTES = %w[GivenName Surname EMailAddress AffiliationRole].freeze

    attr_reader :expires_at, :nbp_uid

    def initialize(options = {})
      skip_fetch = options.delete(:skip_fetch)
      case options.keys
        when [:content]
          template = options[:content]
          @truncated_reference = template[:truncatedReference]
          populate_from_existing template
        when [:truncated_reference]
          @truncated_reference = options[:truncated_reference]
          fetch_existing unless skip_fetch
        when [:nbp_uid]
          @nbp_uid = options[:nbp_uid]
          @expires_at = VALIDITY_PERIOD.from_now
        else
          raise ArgumentError.new('RelationshipTemplate must be initialized with either a `content`, `truncated_reference`, or `nbp_uid`')
      end
    end

    def create!
      @truncated_reference = Connector.create_relationship_template self
      self
    end

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

    def truncated_reference
      raise ConnectorError.new('RelationshipTemplate has not been persisted yet') unless @truncated_reference

      @truncated_reference
    end

    def remaining_validity
      expires_at - Time.zone.now
    end

    def self.create!(nbp_uid:)
      new(nbp_uid:).create!
    end

    def self.display_name_attribute
      @display_name_attribute ||= Attribute::Identity.new(type: 'DisplayName', value: DISPLAY_NAME)
    end

    def to_json(*)
      {
        maxNumberOfAllocations: 1,
        expiresAt: expires_at,
        content: {
          metadata: {nbp_uid:},
          '@type': 'RelationshipTemplateContent',
          onNewRelationship: {
            '@type': 'Request',
            items: shared_attributes + required_attribute_queries,
          },
        },
      }.to_json(*)
    end

    def shared_attributes
      display_name_attribute = self.class.display_name_attribute
      [
        {
          '@type': 'ShareAttributeRequestItem',
          mustBeAccepted: true,
          attribute: display_name_attribute.to_h,
          sourceAttributeId: display_name_attribute.id,
        },
      ]
    end

    def required_attribute_queries
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

    private

    def fetch_existing
      template = Connector.fetch_existing_relationship_template truncated_reference
      return unless template

      populate_from_existing(template)
    end

    def populate_from_existing(template)
      @nbp_uid = template.dig(:content, :metadata, :nbp_uid)
      @expires_at = DateTime.parse(template[:expiresAt])
    end
  end
end
