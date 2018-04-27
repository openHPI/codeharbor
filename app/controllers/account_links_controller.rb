class AccountLinksController < ApplicationController
  load_and_authorize_resource :user
  load_and_authorize_resource :account_links, through: :user
  skip_load_and_authorize_resource :only => [:remove_account_link]

  before_action :set_user
  before_action :set_account_link, only: [:show, :edit, :update, :destroy, :remove_account_link]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.user.authorization')
  end
  # GET /account_links
  # GET /account_links.json
  def index
    @account_links = AccountLink.all
  end

  # GET /account_links/1
  # GET /account_links/1.json
  def show
  end

  # GET /account_links/new
  def new
    @account_link = AccountLink.new
  end

  # GET /account_links/1/edit
  def edit
  end

  # POST /account_links
  # POST /account_links.json
  def create
    @account_link = AccountLink.new(account_link_params)
    @account_link.user = @user
    respond_to do |format|
      if @account_link.save
        format.html { redirect_to @account_link.user, notice: 'Account link was successfully created.' }
        format.json { render :show, status: :created, location: @account_link }
      else
        format.html { render :new }
        format.json { render json: @account_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account_links/1
  # PATCH/PUT /account_links/1.json
  def update
    respond_to do |format|
      if @account_link.update(account_link_params)
        format.html { redirect_to @account_link.user, notice: 'Account link was successfully updated.' }
        format.json { render :show, status: :ok, location: @account_link }
      else
        format.html { render :edit }
        format.json { render json: @account_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account_links/1
  # DELETE /account_links/1.json
  def destroy
    @account_link.destroy
    respond_to do |format|
      format.html { redirect_to @account_link.user, notice: 'Account link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def remove_account_link
    respond_to do |format|
      if @account_link.external_users.delete(@user)
        format.html { redirect_to @user, notice: t('controllers.user.remove_account_link.success') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { redirect_to @user, alert: t('controllers.user.remove_account_link.fail') }
        format.json { render :show, status: :ok, location: @user }
      end
    end
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
      params.require(:account_link).permit(:push_url, :account_name, :oauth2_token, :client_id, :client_secret)
    end
end
