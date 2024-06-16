# frozen_string_literal: true

module Enmeshed
  class Attribute
    delegate :enmeshed_address, to: Enmeshed::Connector

    attr_reader :owner, :type, :value

    def initialize(type:, value:, owner: enmeshed_address, singleton: true)
      # Only subclasses of `Enmeshed::Attribute` should be instantiated
      @owner = owner
      @singleton = singleton
      @type = type
      @value = value
    end

    def to_h
      default_attributes.deep_merge(additional_attributes)
    end

    def id
      @id ||= persistent_id
    end

    def persistent_id
      return create! unless @singleton

      # We need to synchronize the creation of the attribute.
      # Otherwise, we could end up with multiple attributes with the same value.
      self.class.synchronize { fetch_existing || create! }
    end

    def klass
      "#{self.class.name&.demodulize}Attribute"
    end

    private

    def default_attributes
      {
        '@type': klass,
        owner: @owner,
        value: {
          '@type': @type,
          value: @value,
        },
      }
    end

    def additional_attributes
      raise NotImplementedError
    end

    def fetch_existing
      Connector.fetch_existing_attribute self
    end

    def create!
      Connector.create_attribute self
    end

    class << self
      def mutex
        @mutex ||= Mutex.new
      end

      def synchronize(&)
        mutex.synchronize(&)
      end
    end
  end
end
