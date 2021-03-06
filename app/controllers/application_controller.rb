# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  before_action :set_sentry_context
  after_action :flash_to_headers

  # http://www.rubydoc.info/docs/rails/AbstractController/Helpers/ClassMethods:helper_method
  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  private

  def set_sentry_context
    return if current_user.blank?

    Sentry.set_user(id: current_user.id, username: current_user.username)
  end

  def flash_to_headers
    return unless request.xhr?

    response.headers['X-Message'] = flash_message
    response.headers['X-Message-Type'] = flash_type.to_s

    flash.discard # don't want the flash to appear when you reload page
  end

  def flash_message
    %i[alert warning notice].each do |type|
      return flash[type] if flash[type].present?
    end
    ''
  end

  def flash_type
    %i[alert warning notice].each do |type|
      return type if flash[type].present?
    end
    :empty
  end
end
