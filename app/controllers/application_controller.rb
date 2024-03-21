# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pundit::Authorization

  MEMBER_ACTIONS = %i[destroy edit show update].freeze
  MONITORING_USER_AGENT = /updown\.io/

  around_action :mnemosyne_trace
  around_action :switch_locale
  before_action :set_sentry_context, :set_document_policy
  before_action :require_user!
  after_action :verify_authorized
  after_action :flash_to_headers
  protect_from_forgery(with: :exception, prepend: true)
  rescue_from Pundit::NotAuthorizedError, with: :render_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  add_flash_types :danger, :warning, :info, :success

  private

  def require_user!
    raise Pundit::NotAuthorizedError unless current_user
  end

  def flash_to_headers
    return unless request.xhr?

    response.headers['X-Message'] = ERB::Util.url_encode(flash_message)
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
    self.class._flash_types.each do |type|
      return type if flash[type].present?
    end
    :empty
  end

  def set_sentry_context
    return unless user_signed_in?

    Sentry.set_user(id: current_user.id)
  end

  def set_document_policy
    # Instruct browsers to capture profiling data
    response.set_header('Document-Policy', 'js-profiling')
  end

  def render_not_authorized
    render_error t('common.errors.not_authorized'), :unauthorized
  end

  def render_not_found
    if current_user&.role == 'admin'
      render_error t('common.errors.not_found_error'), :not_found
    else
      render_not_authorized
    end
  end

  def render_error(message, status) # rubocop:disable Metrics/AbcSize
    set_sentry_context
    respond_to do |format|
      format.any do
        # Prevent redirect loop
        if request.url == request.referer || request.referer&.match?(new_user_session_path)
          redirect_to :root, alert: message
        elsif current_user.nil? && status == :unauthorized
          store_location_for(:user, request.fullpath) if current_user.nil?
          redirect_to new_user_session_path, alert: t('common.errors.not_signed_in')
        else
          redirect_back fallback_location: :root, allow_other_host: false, alert: message
        end
      end
      format.json { render json: {error: message}, status: }
    end
  end

  def mnemosyne_trace
    yield
  ensure
    if ::Mnemosyne::Instrumenter.current_trace.present?
      ::Mnemosyne::Instrumenter.current_trace.meta['session_id'] = session[:session_id]
      ::Mnemosyne::Instrumenter.current_trace.meta['csrf_token'] = session[:_csrf_token]
    end
  end

  def switch_locale(&) # rubocop:disable Metrics/AbcSize
    session[:locale] = sanitize_locale(params[:custom_locale] || params[:locale] || session[:locale])
    locale = session[:locale] || http_accept_language.compatible_language_from(I18n.available_locales) || I18n.default_locale
    Sentry.set_extras(locale:)
    I18n.with_locale(locale, &)
  end

  # Sanitize given locale.
  #
  # Return `nil` if the locale is blank or not available.
  #
  def sanitize_locale(locale)
    return if locale.blank?

    locale = locale.downcase.to_sym
    return unless I18n.available_locales.include?(locale)

    locale
  end
end
