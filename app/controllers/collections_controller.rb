# frozen_string_literal: true

require 'zip'

class CollectionsController < ApplicationController
  before_action :load_and_authorize_collection, except: %i[index new create]

  def index
    @collections = Collection.member(current_user).or(Collection.public_access).includes(:users, tasks: %i[user groups])
      .order(id: :asc)
      .paginate(page: params[:page], per_page: per_page_param)
      .load

    authorize @collections
  end

  def show
    @num_of_invites = Message.where(param_type: 'collection', param_id: @collection.id).count
  end

  def new
    @collection = Collection.new
    authorize @collection
  end

  def edit; end

  def create
    @collection = Collection.new(collection_params.merge(users: [current_user]))
    authorize @collection

    if @collection.tasks.any?
      # Redirect back to task#show as collections with tasks can only be created from that view
      create_collection_with_task
    elsif @collection.save
      redirect_to collections_path, notice: t('common.notices.object_created', model: Collection.model_name.human)
    else
      render :new
    end
  end

  def update
    if @collection.update(collection_params)
      redirect_to collections_path, notice: t('common.notices.object_updated', model: Collection.model_name.human)
    else
      render :edit
    end
  end

  def remove_task
    redirect_target = params[:return_to_task] ? Task.find(params[:task]) : @collection
    if @collection.remove_task(params[:task])
      redirect_to redirect_target, notice: t('common.notices.object_removed', model: Task.model_name.human)
    else
      redirect_to redirect_target, alert: t('.cannot_remove_alert')
    end
  end

  def remove_all
    if @collection.remove_all
      redirect_to @collection, notice: t('.success_notice')
    else
      redirect_to @collection, alert: t('.cannot_remove_alert')
    end
  end

  def push_collection
    account_link = AccountLink.find(params[:account_link])
    errors = push_exercises

    if errors.empty?
      redirect_to @collection, notice: t('.push_external_notice', account_link: account_link.name)
    else
      errors.each do |error|
        logger.debug(error)
      end
      redirect_to @collection, alert: t('.not_working', account_link: account_link.name)
    end
  end

  def download_all
    binary_zip_data = ProformaService::ExportTasks.call(tasks: @collection.tasks)

    send_data(binary_zip_data.string, type: 'application/zip', filename: "#{@collection.title}.zip", disposition: 'attachment')
  end

  def share
    message = share_message
    if @collection.users.exclude?(share_message.recipient) && message.save
      redirect_to collection_path(@collection), notice: t('.success_notice')
    else
      redirect_to collection_path(@collection), alert: t('common.errors.something_went_wrong')
    end
  end

  def view_shared
    render :show
  end

  def save_shared
    user = current_user
    return redirect_to user_messages_path(user), alert: t('.errors.already_member') if @collection.users.include? user

    @collection.users << user
    Message.received_by(user).find_by(param_type: 'collection', param_id: @collection.id).destroy

    redirect_to @collection, notice: t('.success_notice')
  end

  def leave
    if @collection.users.count == 1
      @collection.destroy
      redirect_to collections_path, notice: t('common.notices.object_deleted', model: Collection.model_name.human)
    else
      @collection.users.delete(current_user)
      redirect_to collections_path, notice: t('.left_successfully')
    end
  end

  private

  def create_collection_with_task
    if @collection.save
      redirect_to @collection.tasks.first, notice: t('collections.create.success_notice')
    else
      flash.now[:alert] = t('collections.create.error')
    end
  end

  def share_message
    user = User.find_by(email: params[:user])
    Message.new(sender: current_user, recipient: user, param_type: 'collection', param_id: @collection.id)
  end

  def push_exercises
    errors = []
    @collection.tasks.each do |exercise|
      error = push_exercise(exercise, account_link) # TODO: implement multi export
      errors << error if error.present?
    end
    errors
  end

  def load_and_authorize_collection
    @collection = Collection.find(params[:id])
    authorize @collection
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def collection_tasks_params
    %i[id rank _destroy]
  end

  def collection_params
    params.require(:collection).permit(:title, :task_ids, :visibility_level, :description,
      collection_tasks_attributes: collection_tasks_params)
  end
end
