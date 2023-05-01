# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource

  def search
    page = params[:page].to_i
    if page <= 0
      page = 1
    end

    results = Label.ransack(name_i_cont: params[:search]).result
    paginated = results.paginate(per_page: 3, page:)

    response = {
      results: paginated.map {|l| {id: l.name, text: l.name, label_color: l.color, label_font_color: l.font_color} },
      pagination: {more: (page * 3 < results.length)},
    }
    render json: response
  end
end
