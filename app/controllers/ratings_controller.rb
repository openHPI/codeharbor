# frozen_string_literal: true

class RatingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_task

  rescue_from CanCan::AccessDenied, ActiveRecord::RecordNotFound do |_exception|
    redirect_to root_path, alert: t('controllers.rating.authorization')
  end

  def create
    return handle_own_rating if @task.user == current_user

    rating, notice = handle_rating
    if rating.save
      overall_rating = @task.average_rating
      render json: {overall_rating:, user_rating: rating}
      flash.now[:notice] = notice
    else
      render json: {notice: t('controllers.generic_error')}
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def rating_params
    params.require(:rating).permit(:rating, :task_id)
  end

  def handle_own_rating
    flash.now[:alert] = t('controllers.rating.own_task')
    overall_rating = @task.average_rating
    render json: {overall_rating:, user_rating: overall_rating}
  end

  def handle_rating
    rating = @task.ratings.find_or_initialize_by(user: current_user)
    rating.rating = rating_params[:rating]

    notice = rating.persisted? ? t('controllers.rating.success.update') : t('controllers.rating.success.create')

    [rating, notice]
  end
end
