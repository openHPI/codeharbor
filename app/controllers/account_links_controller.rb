# frozen_string_literal: true

class AccountLinksController < ApplicationController
  load_and_authorize_resource

  before_action :set_user
  before_action :set_account_link, only: %i[show edit update destroy]
  before_action :set_shared_user, only: %i[remove_shared_user add_shared_user]

  rescue_from CanCan::AccessDenied, ActiveRecord::RecordNotFound do |_exception|
    redirect_to root_path, alert: t('controllers.user.authorization')
  end

  def show; end

  def new
    @account_link = AccountLink.new(
      push_url: "#{Settings.codeocean.url}/import_task",
      check_uuid_url: "#{Settings.codeocean.url}/import_uuid_check"
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
    @account_link.shared_users.destroy(@shared_user)
    flash.now[:notice] = t('controllers.account_links.removed_push', user: @shared_user.email)
    render_shared_user_json
  end

  def add_shared_user
    @account_link.shared_users << @shared_user
    flash.now[:notice] = t('controllers.account_links.granted_push', user: @shared_user.email)
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = t('controllers.account_links.share_duplicate', user: @shared_user.email)
  ensure
    render_shared_user_json
  end

  private

  def render_shared_user_json
    render json: {button: render_to_string(partial: 'groups/share_account_link_button',
                                           locals: {shared_user: @shared_user, account_link: @account_link})}
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_account_link
    @account_link = AccountLink.find(params[:id])
  end

  def set_shared_user
    @shared_user = User.find(params[:shared_user])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def account_link_params
    params.require(:account_link).permit(:push_url, :check_uuid_url, :api_key, :name)
  end
end
