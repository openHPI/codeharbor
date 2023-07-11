# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.authorization')
  end

  def index; end

  def update
    @label.update(params.permit(:color))
  end

  def destroy
    @label.destroy
  end

  def merge
    label_ids = params[:label_ids]

    ApplicationRecord.transaction do
      Label.find(label_ids.first).update!(
        name: params[:new_label_name],
        tasks: Task.where(id: TaskLabel.select(:task_id).where(label_id: label_ids))
      )
      Label.destroy(label_ids[1..])
    rescue StandardError => e
      render json: e, status: :unprocessable_entity
      raise ActiveRecord::Rollback
    end
  end

  def search
    paginated = Label.ransack(params[:search]).result.paginate(per_page: 3, page: params[:page])

    if current_user.role == 'admin' && params[:more_info]
      paginated = paginated.includes(:tasks)
    end

    render json: {results: paginated.map(&:to_h), pagination: {more: paginated.next_page.present?}}
  end
end
