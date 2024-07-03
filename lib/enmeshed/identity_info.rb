# frozen_string_literal: true

module Enmeshed
  class IdentityInfo < Object
    attr_reader :address, :public_key

    def initialize(address:, public_key:)
      @address = address
      @public_key = public_key
    end

    def self.parse(content)
      super
      new(address: content[:address], public_key: content[:publicKey])
    end
  end
end
