# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.authorization')
  end

  def index; end

  def update
    if @label.update(params.permit(:color))
      render json: @label.to_h
    else
      flash.now[:alert] = @label.errors.full_messages
      render json: @label.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @label.destroy
  end

  def merge # rubocop:disable Metrics/AbcSize
    label_ids = params[:label_ids] || []

    ApplicationRecord.transaction do
      tasks = Task.where(id: TaskLabel.select(:task_id).where(label_id: label_ids))
      Label.destroy(label_ids[1..])
      Label.find(label_ids.first).update!(name: params[:new_label_name], tasks:)
    rescue ActiveRecord::RecordNotFound => e
      flash.now[:alert] = e.message
      render json: e.message, status: :unprocessable_entity
      raise ActiveRecord::Rollback
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages
      render json: e.record.errors.full_messages, status: :unprocessable_entity
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
