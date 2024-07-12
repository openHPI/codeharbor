# frozen_string_literal: true

module Enmeshed
  class Attribute::Relationship < Attribute
    attr_reader :key

    def initialize(key:, **)
      @key = key
      super(**)
    end

    private

    def additional_attributes
      {
        key:,
        confidentiality: 'private',
        isTechnical: true,
        value: {
          title: I18n.t("users.nbp_wallet.enmeshed.#{key}"),
        },
      }
    end
  end
end
