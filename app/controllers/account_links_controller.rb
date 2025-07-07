# frozen_string_literal: true

class AccountLinksController < ApplicationController
  before_action :load_and_authorize_account_link, except: %i[new create]
  before_action :set_user
  before_action :set_shared_user, only: %i[remove_shared_user add_shared_user]

  def show; end

  def new
    @account_link = AccountLink.new(
      push_url: "#{Settings.codeocean.url}/import_task",
      check_uuid_url: "#{Settings.codeocean.url}/import_uuid_check"
    )
    authorize @account_link
  end

  def edit; end

  def create # rubocop:disable Metrics/AbcSize
    @account_link = AccountLink.new(account_link_params)
    @account_link.user = @user
    authorize @account_link

    respond_to do |format|
      if @account_link.save
        format.html do
          redirect_to @user, notice: t('common.notices.object_created', model: AccountLink.model_name.human), status: :see_other
        end
        format.json { render :show, status: :created, location: @account_link }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @account_link.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @account_link.update(account_link_params)
        format.html do
          redirect_to @account_link.user,
            notice: t('common.notices.object_updated', model: AccountLink.model_name.human),
            status: :see_other
        end
        format.json { render :show, status: :ok, location: @account_link }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @account_link.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @account_link.destroy
    respond_to do |format|
      format.html do
        redirect_to @account_link.user, notice: t('common.notices.object_deleted', model: AccountLink.model_name.human), status: :see_other
      end
      format.json { head :no_content }
    end
  end

  def remove_shared_user
    @account_link.shared_users.destroy(@shared_user)
    flash.now[:notice] = t('.removed_push', user: @shared_user.email)
    render_shared_user_json
  end

  def add_shared_user
    @account_link.shared_users << @shared_user
    flash.now[:notice] = t('.granted_push', user: @shared_user.email)
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = t('.share_duplicate', user: @shared_user.email)
  ensure
    render_shared_user_json
  end

  private

  def render_shared_user_json
    render json: {button: render_to_string(partial: 'groups/share_account_link_button',
      locals: {shared_user: @shared_user, account_link: @account_link})}
  end

  # Use callbacks to share common setup or constraints between actions.
  def load_and_authorize_account_link
    @account_link = AccountLink.find(params[:id])
    authorize @account_link
  end

  def set_shared_user
    @shared_user = User.find(params[:shared_user])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def account_link_params
    params.expect(account_link: %i[push_url check_uuid_url api_key name proforma_version])
  end
end
