# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  before_action :set_sentry_context
  after_action :flash_to_headers

  rescue_from CanCan::AccessDenied do |_exception|
    if current_user
      begin
        redirect_to({action: :index}, alert: t('controllers.authorization'))
      rescue ActionController::UrlGenerationError
        redirect_to root_path, alert: t('controllers.authorization')
      end
    else
      redirect_to root_path, alert: t('controllers.authorization')
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    redirect_to({action: :index}, alert: t('controllers.not_found'))
  rescue ActionController::UrlGenerationError
    redirect_to root_path, alert: t('controllers.not_found')
  end

  private

  def set_sentry_context
    return unless user_signed_in?

    Sentry.set_user(id: current_user.id)
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
