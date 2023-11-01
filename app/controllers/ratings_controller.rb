# frozen_string_literal: true

class RatingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_task

  def create
    return handle_own_rating if @task.user == current_user

    rating, notice = handle_rating
    if rating.save
      overall_rating = @task.average_rating
      render json: {overall_rating:, user_rating: rating}
      flash.now[:notice] = notice
    else
      render json: {notice: t('common.errors.generic')}
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
    flash.now[:alert] = t('ratings.handle_own_rating.error')
    overall_rating = @task.average_rating
    render json: {overall_rating:, user_rating: overall_rating}
  end

  def handle_rating
    rating = @task.ratings.find_or_initialize_by(user: current_user)
    rating.rating = rating_params[:rating]

    notice = rating.persisted? ? t('ratings.handle_rating.rating_updated') : t('ratings.handle_rating.rating_created')

    [rating, notice]
  end
end
