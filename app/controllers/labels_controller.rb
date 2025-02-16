# frozen_string_literal: true

class LabelsController < ApplicationController
  before_action :load_and_authorize_label, except: %i[index merge search]
  before_action :only_authorize_action, only: %i[index merge search]

  def index; end

  def update
    if @label.update(label_params)
      render json: @label.to_h
    else
      flash.now[:alert] = @label.errors.full_messages
      render json: @label.errors.full_messages, status: :unprocessable_content
    end
  end

  delegate :destroy, to: :@label

  def merge # rubocop:disable Metrics/AbcSize
    label_ids = params[:label_ids] || []

    ApplicationRecord.transaction do
      tasks = Task.where(id: TaskLabel.select(:task_id).where(label_id: label_ids))
      Label.destroy(label_ids[1..])
      Label.find(label_ids.first).update!(name: params[:new_label_name], tasks:)
    rescue ActiveRecord::RecordNotFound => e
      flash.now[:alert] = e.message
      render json: e.message, status: :unprocessable_content
      raise ActiveRecord::Rollback
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages
      render json: e.record.errors.full_messages, status: :unprocessable_content
      raise ActiveRecord::Rollback
    end
  end

  def search # rubocop:disable Metrics/AbcSize
    paginated = Label.ransack(params[:q]).result.paginate(page: params[:page], per_page: per_page_param)

    if current_user.role == 'admin' && params[:more_info]
      paginated = paginated.includes(:tasks)
    end

    render json: {results: paginated.map(&:to_h), pagination: {more: paginated.next_page.present?}}
  end

  private

  def label_params
    params.expect(label: [:color])
  end

  def load_and_authorize_label
    @label = Label.find(params[:id])
    authorize @label
  end

  def only_authorize_action
    authorize Label
  end
end
