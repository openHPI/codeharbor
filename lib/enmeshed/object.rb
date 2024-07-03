# frozen_string_literal: true

module Enmeshed
  class Object
    delegate :klass, to: :class

    def self.parse(content)
      validate! content
    end

    def self.klass
      name&.demodulize
    end

    def self.schema
      @schema ||= Connector::API_SCHEMA.schema(klass)
    end

    def self.validate!(instance)
      raise ConnectorError.new("Invalid #{klass} schema") unless schema.valid?(instance)
    end
  end
end
