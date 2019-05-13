# frozen_string_literal: true

require 'zip'
require 'proforma/xml_generator'

class CollectionsController < ApplicationController
  load_and_authorize_resource
  before_action :set_collection, only: %i[show edit update destroy remove_exercise remove_all download_all share view_shared save_shared]
  before_action :new_collection, only: :create

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.collections.authorization')
  end

  include ExerciseExport

  # GET /collections
  # GET /collections.json
  def index
    @collections = Collection.includes(:collection_users)
                             .where(collection_users: {user: current_user})
                             .distinct
                             .paginate(per_page: 5, page: params[:page])
  end

  def collections_all
    @collections = Collection.all.paginate(per_page: 10, page: params[:page])
  end

  def show; end

  def new
    @collection = Collection.new
  end

  def edit; end

  def create
    respond_to do |format|
      if @collection.save
        format.html { redirect_to collections_path, notice: t('controllers.collections.created') }
        format.json { render :index, status: :created, location: @collection }
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to collections_path, notice: t('controllers.collections.updated') }
        format.json { render :index, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_exercise
    if @collection.remove_exercise(params[:exercise])
      redirect_to @collection, notice: t('controllers.collections.remove_exercise_success')
    else
      redirect_to @collection, alert: t('controllers.collections.remove_exercise_fail')
    end
  end

  def remove_all
    if @collection.remove_all
      redirect_to @collection, notice: t('controllers.collections.remove_all_success')
    else
      redirect_to @collection, alert: t('controllers.collections.remove_all_fail')
    end
  end

  def push_collection
    account_link = AccountLink.find(params[:account_link])
    errors = push_exercises

    if errors.empty?
      redirect_to @collection, notice: t('controllers.exercise.push_external_notice', account_link: account_link.readable)
    else
      errors.each do |error|
        logger.debug(error)
      end
      redirect_to @collection, alert: "Your account_link #{account_link.readable} does not seem to be working."
    end
  end

  def download_all
    binary_zip_data = ProformaService::ExportTasks.call(exercises: @collection.exercises)

    send_data(binary_zip_data.string, type: 'application/zip', filename: "#{@collection.title}.zip", disposition: 'attachment')
  end

  # def send_zip(exercises)
  #   Zip::OutputStream.write_buffer do |zio|
  #     exercises.each do |exercise|
  #       zip_file = create_exercise_zip(exercise)
  #       if zip_file[:errors].any?
  #         zip_file[:errors].each do |error|
  #           logger.debug(error)
  #         end
  #       else
  #         zio.put_next_entry(zip_file[:filename])
  #         zio.write zip_file[:data]
  #       end
  #     end
  #   end
  # end

  def share
    if share_message.save
      redirect_to collection_path(@collection), notice: t('controllers.collections.share.notice')
    else
      redirect_to collection_path(@collection), alert: t('controllers.collections.share.alert')
    end
  end

  def view_shared
    @user = User.find(params[:user])
    render :show
  end

  def save_shared
    @collection.users << current_user

    if @collection.save
      redirect_to collection_path(@collection), notice: t('controllers.collections.save_shared.notice')
    else
      redirect_to users_messages_path, alert: t('controllers.collections.save_shared.alert')
    end
  end

  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: t('controllers.collections.destroyed') }
      format.json { head :no_content }
    end
  end

  private

  def new_collection
    @collection = Collection.new(collection_params)
    @collection.users << current_user
  end

  def share_message
    user = User.find_by(email: params[:user])
    text = t('controllers.collections.share.text', user: current_user.name, collection: @collection.title)
    Message.new(sender: current_user, recipient: user, param_type: 'collection', param_id: @collection.id, text: text)
  end

  def push_exercises
    errors = []
    @collection.exercises.each do |exercise|
      error = push_exercise(exercise, account_link)
      errors << error if error.present?
    end
    errors
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_collection
    @collection = Collection.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def collection_params
    params.require(:collection).permit(:title)
  end
end
