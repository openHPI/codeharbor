# frozen_string_literal: true

class RatingsController < ApplicationController
  before_action :load_and_authorize_base_task

  def create # rubocop:disable Metrics/AbcSize
    return handle_own_rating if @task.user == current_user

    rating, notice = handle_rating
    authorize rating

    if rating.save
      flash.now[:notice] = notice
    else
      flash.now[:alert] = rating.errors.full_messages.join('. ')
    end
    render json: {average_rating: @task.average_rating}
  end

  private

  def load_and_authorize_task
    @task = Task.find(params[:task_id])
    authorize @task, :show?
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def rating_params
    params.require(:rating).permit(Rating::CATEGORIES)
  end

  def handle_own_rating
    flash.now[:alert] = t('ratings.handle_own_rating.error')
    render json: {average_rating: @task.average_rating}
  end

  def handle_rating
    rating = @task.ratings.find_or_initialize_by(user: current_user)
    rating.assign_attributes(rating_params)

    notice = t(rating.persisted? ? 'common.notices.object_updated' : 'common.notices.object_created', model: Rating.model_name.human)

    [rating, notice]
  end
end
