# frozen_string_literal: true

class RailsAdminController < ApplicationController
  # RailsAdmin does not include translations. Therefore, we fallback to English locales
  skip_around_action :switch_locale
end
