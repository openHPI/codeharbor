# frozen_string_literal: true

require 'zip'

class CartsController < ApplicationController
  load_and_authorize_resource
  before_action :set_cart, only: %i[show edit update destroy remove_exercise remove_all download_all]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.carts.authorization')
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
