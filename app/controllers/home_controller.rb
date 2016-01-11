class HomeController < ApplicationController
  def index
    @exercises = Exercise.search(params[:search]).paginate(per_page: 5, page: params[:page])
  end
end
