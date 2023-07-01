# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.authorization')
  end

  def index
    @search = {}
  end

  def merge
    label_ids = params[:label_ids]
    new_name = params[:new_label_name]

    if new_name.length.positive? && new_name.length < 15
      new_label = Label.create(name: new_name)
      new_label.tasks = Task.where(id: TaskLabel.select(:task_id).where(label_id: label_ids).distinct)
      Label.where(id: label_ids).destroy_all
    else
      head :bad_request
    end
  end

  def set_color
    new_color = params[:new_color]
    if /^[0-9a-fA-F]{6}$/.match?(new_color)
      updates = params[:label_ids].map { {'color' => new_color} }
      Label.update(params[:label_ids], updates)
    else
      head :bad_request
    end
  end

  def destroy
    Label.where(id: params[:label_ids]).destroy_all
  end

  def search # rubocop:disable Metrics/AbcSize
    paginated = Label.ransack(params[:search]).result.paginate(per_page: 3, page: params[:page])

    render json: {
      results: paginated.map do |l|
        l.attributes.merge(
          font_color: l.font_color,
          used_by_tasks: l.tasks.count,
          created_at: l.created_at.to_fs(:rfc822),
          updated_at: l.updated_at.to_fs(:rfc822)
        )
      end,
      pagination: {more: paginated.next_page.present?},
    }
  end
end
