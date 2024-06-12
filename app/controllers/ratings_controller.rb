# frozen_string_literal: true

class RatingsController < ApplicationController
  before_action :load_and_authorize_task

  def create
    return handle_own_rating if @task.user == current_user

    rating, notice = handle_rating
    authorize rating

    if rating.save
      overall_rating = @task.average_rating
      render json: {overall_rating:, user_rating: rating}
      flash.now[:notice] = notice
    else
      render json: {notice: t('common.errors.generic')}
    end
  end

  private

  def load_and_authorize_task
    @task = Task.find(params[:task_id])
    authorize @task, :show?
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

    notice = if rating.persisted?
               t('common.notices.object_updated',
                 model: Rating.model_name.human)
             else
               t('common.notices.object_created', model: Rating.model_name.human)
             end

    [rating, notice]
  end
end
