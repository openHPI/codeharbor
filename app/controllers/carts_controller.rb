# frozen_string_literal: true

require 'zip'

class CartsController < ApplicationController
  load_and_authorize_resource
  before_action :set_cart, only: %i[show edit update destroy remove_exercise remove_all download_all]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.carts.authorization')
  end

  def index
    @carts = Cart.all
  end

  def show; end

  def new
    @cart = Cart.new
  end

  def edit; end

  def create
    @cart = Cart.new
    @cart.user = current_user

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: t('controllers.carts.created') }
        format.json { render :show, status: :created, location: @cart }
      else
        format.html { render :new }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cart.update(user: @user)
        format.html { redirect_to carts_path, notice: t('controllers.carts.updated') }
        format.json { render :index, status: :ok, location: @cart }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cart.destroy
    respond_to do |format|
      format.html { redirect_to carts_url, notice: t('controllers.carts.destroyed') }
      format.json { head :no_content }
    end
  end

  def remove_exercise
    if @cart.remove_exercise(params[:exercise])
      redirect_to @cart, notice: t('controllers.carts.remove_exercise_success')
    else
      redirect_to @cart, alert: t('controllers.carts.remove_exercise_fail')
    end
  end

  def remove_all
    if @cart.remove_all
      redirect_to @cart, notice: t('controllers.carts.remove_all_success')
    else
      redirect_to @cart, alert: t('controllers.carts.remove_all_fail')
    end
  end

  def push_cart
    @account_link = AccountLink.find(params[:account_link])
    errors = push_exercises

    if errors.empty?
      redirect_to @cart, notice: t('controllers.exercise.push_external_notice', account_link: @account_link.name)
    else
      errors.each do |error|
        logger.error(error)
      end
      redirect_to @cart, alert: t('controllers.account_links.not_working', account_link: @account_link.name)
    end
  end

  def download_all
    filename = t('controllers.carts.zip_filename', date: Time.zone.today.strftime)

    binary_zip_data = ProformaService::ExportTasks.call(exercises: @cart.exercises)
    @cart.exercises.each { |exercise| exercise.update(downloads: exercise.downloads + 1) }
    send_data(binary_zip_data.string, type: 'application/zip', filename: filename, disposition: 'attachment')
  end

  def my_cart
    @cart = Cart.find_cart_of(current_user)
    redirect_to cart_path(@cart)
  end

  private

  def push_exercises
    @cart.exercises.each do |exercise|
      error = push_exercise(exercise, @account_link) # TODO: implement multi export
      errors << error if error.present?
    end
    errors
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_cart
    @cart = Cart.find(params[:id])
  end
end
