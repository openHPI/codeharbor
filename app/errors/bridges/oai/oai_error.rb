# frozen_string_literal: true

module Bridges
  module Oai
    class OaiError < StandardError
      attr_reader :code

      def initialize(msg, code)
        @code = code
        super(msg)
      end
    end
  end
end
