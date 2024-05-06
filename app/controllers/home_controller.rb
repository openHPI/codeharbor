# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :require_user!
  skip_after_action :verify_authorized

  def index; end

  def about
    render 'about'
  end

  def account_link_documentation
    render 'account_link_documentation'
  end
end
