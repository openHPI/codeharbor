# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource
  skip_load_and_authorize_resource only: %i[new create]
  before_action :set_user, only: %i[show edit update destroy]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.user.authorization')
  end
  # GET /users
  # GET /users.json
  def index
    @users = User.all.paginate(per_page: 10, page: params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    Cart.create(user: @user)

    respond_to do |format|
      if @user.save
        UserMailer.registration_confirmation(@user).deliver_now
        format.html { redirect_to home_index_path, notice: t('controllers.user.confirm_email') }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user.avatar = nil if params[:user][:avatar].nil? && params[:user][:avatar_present] == 'false'
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: t('controllers.user.updated') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    respond_to do |format|
      if @user.soft_delete
        format.html { redirect_to users_url, notice: t('controllers.user.destroyed') }
        format.json { head :no_content }
      else
        format.html { redirect_to users_url, alert: t('controllers.user.last_admin') }
        format.json { head :no_content }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:avatar, :username, :description, :first_name, :last_name, :email, :password, :password_confirmation)
  end
end
