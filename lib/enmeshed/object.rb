# frozen_string_literal: true

module Enmeshed
  class Object
    delegate :klass, to: :class

    class << self
      def parse(content)
        validate! content
      end

      def klass
        name&.demodulize
      end

      def schema
        @schema ||= Connector::API_SCHEMA.schema(klass)
      end

      def validate!(instance)
        unless schema.valid?(instance)
          error = schema.validate(instance).first.fetch('error')
          Rails.logger.debug { "Invalid #{klass} schema: #{error}" }
          raise ConnectorError.new("Invalid #{klass} schema: #{error}")
        end
      end
    end
  end
end
