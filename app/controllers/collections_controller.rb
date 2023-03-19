# frozen_string_literal: true

require 'zip'

class CollectionsController < ApplicationController
  load_and_authorize_resource
  before_action :set_collection, only: %i[show edit update remove_task remove_all download_all share view_shared save_shared]
  before_action :new_collection, only: :create

  def index
    @collections = Collection.includes(:collection_users)
      .where(collection_users: {user: current_user})
      .distinct
      .paginate(per_page: 5, page: params[:page])
  end

  def show; end

  def new
    @collection = Collection.new
  end

  def edit; end

  def create
    if @collection.save
      redirect_to collections_path, notice: t('controllers.collections.created')
    else
      render :new
    end
  end

  def update
    if @collection.update(collection_params)
      redirect_to collections_path, notice: t('controllers.collections.updated')
    else
      render :edit
    end
  end

  def remove_task
    if @collection.remove_task(params[:task])
      redirect_to @collection, notice: t('controllers.collections.remove_task_success')
    else
      redirect_to @collection, alert: t('controllers.collections.remove_task_fail')
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
      redirect_to @collection, notice: t('controllers.exercise.push_external_notice', account_link: account_link.name)
    else
      errors.each do |error|
        logger.debug(error)
      end
      redirect_to @collection, alert: t('controllers.account_links.not_working', account_link: account_link.name)
    end
  end

  def download_all
    binary_zip_data = ProformaService::ExportTasks.call(tasks: @collection.tasks)

    send_data(binary_zip_data.string, type: 'application/zip', filename: "#{@collection.title}.zip", disposition: 'attachment')
  end

  def share
    if share_message.save
      redirect_to collection_path(@collection), notice: t('controllers.collections.share.notice')
    else
      redirect_to collection_path(@collection), alert: t('controllers.collections.share.alert')
    end
  end

  def view_shared
    @user = User.find(params[:user])
    raise CanCan::AccessDenied if @collection.users.exclude?(@user)

    render :show
  end

  def save_shared
    raise CanCan::AccessDenied unless Message.received_by(current_user).exists?(param_type: 'collection', param_id: @collection.id)

    @collection.users << current_user
    if @collection.save
      redirect_to @collection, notice: t('controllers.collections.save_shared.notice')
    else
      redirect_to users_messages_path, alert: t('controllers.collections.save_shared.alert')
    end
  end

  def leave
    if @collection.users.count == 1
      @collection.destroy
      redirect_to collections_path, notice: t('controllers.collection.leave.confirm_destroy')
    else
      @collection.users.delete(current_user)
      redirect_to collections_path, notice: t('controllers.collection.leave.confirm_leave')
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
    Message.new(sender: current_user, recipient: user, param_type: 'collection', param_id: @collection.id, text:)
  end

  def push_exercises
    errors = []
    @collection.tasks.each do |exercise|
      error = push_exercise(exercise, account_link) # TODO: implement multi export
      errors << error if error.present?
    end
    errors
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_collection
    @collection = Collection.find(params[:id])
    raise CanCan::AccessDenied if @collection.users.exclude?(current_user) && action_name != 'save_shared'
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def collection_params
    params.require(:collection).permit(:title)
  end
end
