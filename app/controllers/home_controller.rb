class HomeController < ApplicationController
  def index
    @index = true
  end

  def about
    render 'about'
  end
end
