# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource
  def search
    results = Label.ransack(name_i_cont: params[:search]).result
    paginated = results.paginate(per_page: 3, page: params[:page])

    render json: {
      results: paginated.map {|l| {id: l.name, text: l.name, label_color: l.color, label_font_color: l.font_color} },
      pagination: {more: paginated.next_page.present?},
    }
  end
end
