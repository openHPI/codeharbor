# frozen_string_literal: true

module Gpt
  class Error < ApplicationError
    class InternalServerError < Error; end

    class InvalidApiKey < Error; end

    class InvalidTaskDescription < Error; end

    class MissingLanguage < Error; end

    def localized_message
      I18n.t("errors.gpt.#{self.class.name&.demodulize&.underscore}")
    end
  end
end
