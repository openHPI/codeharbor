# frozen_string_literal: true

class AccountLinksController < ApplicationController
  load_and_authorize_resource

  before_action :set_user
  before_action :set_account_link, only: %i[show edit update destroy remove_account_link]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.user.authorization')
  end

  def show; end

  def new
    @account_link = AccountLink.new(
      push_url: Settings.codeocean.url + '/import_exercise',
      check_uuid_url: Settings.codeocean.url + '/import_uuid_check'
    )
  end

  def edit; end

  def create
    @account_link = AccountLink.new(account_link_params)
    @account_link.user = @user
    respond_to do |format|
      if @account_link.save
        format.html { redirect_to @user, notice: t('controllers.account_links.created') }
        format.json { render :show, status: :created, location: @account_link }
      else
        format.html { render :new }
        format.json { render json: @account_link.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @account_link.update(account_link_params)
        format.html { redirect_to @account_link.user, notice: t('controllers.account_links.updated') }
        format.json { render :show, status: :ok, location: @account_link }
      else
        format.html { render :edit }
        format.json { render json: @account_link.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @account_link.destroy
    respond_to do |format|
      format.html { redirect_to @account_link.user, notice: t('controllers.account_links.destroyed') }
      format.json { head :no_content }
    end
  end

  def remove_shared_user
    @account_link.shared_users.destroy(@user)
    redirect_to @account_link, notice: t('controllers.group.removed_push')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account_link
    @account_link = AccountLink.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def account_link_params
    params.require(:account_link).permit(:push_url, :check_uuid_url, :api_key, :name)
  end
end
