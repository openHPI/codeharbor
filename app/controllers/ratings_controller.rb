# frozen_string_literal: true

class RatingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise

  rescue_from CanCan::AccessDenied, ActiveRecord::RecordNotFound do |_exception|
    redirect_to root_path, alert: t('controllers.rating.authorization')
  end

  def create
    return handle_own_rating if @exercise.user == current_user

    rating = handle_rating

    respond_to do |format|
      if rating.save
        overall_rating = @exercise.round_avg_rating
        format.json { render json: {overall_rating: overall_rating, user_rating: rating} }
      else
        format.json { render layout: false, notice: t('controllers.generic_error') }
      end
    end
  end

  private

  def set_exercise
    @exercise = Exercise.find(params[:exercise_id])
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def rating_params
    params.require(:rating).permit(:rating, :exercise_id, :user_id)
  end

  def handle_own_rating
    flash.now[:alert] = t('controllers.rating.own_exercise')
    overall_rating = @exercise.round_avg_rating
    respond_to do |format|
      format.json { render json: {overall_rating: overall_rating, user_rating: overall_rating} }
    end
  end

  def handle_rating
    rating = @exercise.ratings.find_by(user: current_user)
    notice = t('controllers.rating.success.create')
    if rating
      notice = t('controllers.rating.success.update')
      rating.update(rating_params)
    else
      rating = Rating.new(rating_params)
    end
    rating.exercise = @exercise
    rating.user = current_user
    flash[:notice] = notice

    rating
  end
end
