# frozen_string_literal: true

module AuthenticatedUrlHelper
  class << self
    def add_query_parameters(url, parameters)
      parsed_url = URI.parse url

      # Add the given parameters to the query string
      query_params = CGI.parse(parsed_url.query || '').with_indifferent_access
      query_params.merge!(parameters)

      # Add the query string back to the URL
      parsed_url.query = URI.encode_www_form(query_params).presence

      # Return the full URL
      parsed_url.to_s
    rescue URI::InvalidURIError
      url
    end
  end
end
