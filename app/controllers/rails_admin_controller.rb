# frozen_string_literal: true

class RailsAdminController < ApplicationController
  # RailsAdmin does not include translations. Therefore, we fallback to English locales
  skip_around_action :switch_locale

  skip_before_action :require_user! # authorization is done in the rails admin initializer
  skip_after_action :verify_authorized
end
