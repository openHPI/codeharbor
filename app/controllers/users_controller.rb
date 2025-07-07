# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :load_and_authorize_user

  rescue_from Pundit::NotAuthorizedError do |_exception|
    if current_user
      redirect_to({id: current_user.id}, alert: t('common.errors.not_authorized'), status: :see_other)
    else
      redirect_to :root, alert: t('common.errors.not_authorized'), status: :see_other
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    # leak no information whether a user exists or not if the accessing user is not an admin
    redirect_to({id: current_user.id},
      alert: current_user.role == 'admin' ? t('common.errors.not_found_error') : t('common.errors.not_authorized'), status: :see_other)
  end

  def show; end

  private

  def load_and_authorize_user
    @user = User.find(params[:id])
    authorize @user
  end
end
