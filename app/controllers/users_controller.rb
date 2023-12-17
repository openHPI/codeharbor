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
      # leak no information whether a user exists or not if the accessing user is not an admin
      redirect_to({id: current_user.id},
        alert: current_user.role == 'admin' ? t('common.errors.not_found_error') : t('common.errors.not_authorized'))
    else
      redirect_to root_path, alert: t('common.errors.not_authorized')
    end
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end
end
