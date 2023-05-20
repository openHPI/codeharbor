# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource

  before_action :sanitize_page_param, only: :search
  def search
    results = Label.ransack(name_i_cont: params[:search]).result
    paginated = results.paginate(per_page: 3, page: @page)

    render json: {
      results: paginated.map {|l| {id: l.name, text: l.name, label_color: l.color, label_font_color: l.font_color} },
      pagination: {more: (@page * 3 < results.length)},
    }
  end

  def sanitize_page_param
    @page = params[:page].to_i
    if @page <= 0
      @page = 1
    end
  end
end
