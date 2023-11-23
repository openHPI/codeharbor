# frozen_string_literal: true

class UsersController < ApplicationController
  rescue_from Pundit::NotAuthorizedError do |_exception|
    if current_user
      redirect_to({id: current_user.id}, alert: t('common.errors.not_authorized'))
    else
      redirect_to root_path, alert: t('common.errors.not_authorized')
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    if current_user
      redirect_to({id: current_user.id}, alert: t('common.errors.not_found_error'))
    else
      redirect_to root_path, alert: t('common.errors.not_found_error')
    end
  end

  def index
    @users = User.all.paginate(page: params[:page], per_page: per_page_param)
    authorize @users
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end
end
