# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @index = true
  end

  def about
    render 'about'
  end

  def account_link_documentation
    render 'account_link_documentation'
  end
end
