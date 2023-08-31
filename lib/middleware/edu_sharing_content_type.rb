# frozen_string_literal: true

module Middleware
  class EduSharingContentType
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      fix_content_type(request) if invalid_content_type?(request)
      @app.call(env)
    end

    private

    def invalid_content_type?(request)
      request.get_header('CONTENT_TYPE') == 'charset=UTF-8'
    end

    def fix_content_type(request)
      request.set_header('CONTENT_TYPE', 'text/plain; charset=UTF-8')
    end
  end
end
