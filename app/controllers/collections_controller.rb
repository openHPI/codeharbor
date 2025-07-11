# frozen_string_literal: true

require 'zip'

class CollectionsController < ApplicationController
  before_action :load_and_authorize_collection, except: %i[index new create]
  before_action :set_option, only: %i[index]
  before_action :load_and_authorize_account_link, only: %i[push_collection]

  def index
    @collections = case @option
                     when 'favorites'
                       Collection.member(current_user).or(Collection.public_access).favorites(current_user)
                     when 'public'
                       Collection.public_access
                     else
                       Collection.member(current_user)
                   end
      .includes(:users, collection_tasks: [task: %i[user groups]]).order(title: :asc)
      .paginate(page: params[:page], per_page: per_page_param)

    authorize @collections
  end

  def show
    @num_of_invites = @collection.messages.where(action: :collection_shared).where.not(recipient_status: :deleted).count
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
      redirect_to Collection, notice: t('common.notices.object_created', model: Collection.model_name.human), status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @collection.update(collection_params)
      redirect_to Collection, notice: t('common.notices.object_updated', model: Collection.model_name.human), status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def remove_task
    redirect_target = params[:return_to_task] ? Task.find(params[:task]) : @collection
    if @collection.remove_task(params[:task])
      redirect_to redirect_target, notice: t('common.notices.object_removed', model: Task.model_name.human), status: :see_other
    else
      redirect_to redirect_target, alert: t('.cannot_remove_alert'), status: :see_other
    end
  end

  def remove_all
    if @collection.remove_all
      redirect_to @collection, notice: t('.success_notice'), status: :see_other
    else
      redirect_to @collection, alert: t('.cannot_remove_alert'), status: :see_other
    end
  end

  def push_collection
    errors = push_tasks

    if errors.empty?
      redirect_to @collection, notice: t('.push_external_notice', account_link: @account_link.name), status: :see_other
    else
      errors.each do |error|
        logger.debug(error)
      end
      redirect_to @collection, alert: t('.not_working', account_link: @account_link.name), status: :see_other
    end
  end

  def download_all
    binary_zip_data = ProformaService::ExportTasks.call(tasks: @collection.tasks, options: {version: params[:version]})
    send_data(binary_zip_data.string, type: 'application/zip', filename: "#{@collection.title}.zip", disposition: 'attachment')
  rescue ProformaXML::PostGenerateValidationError => e
    redirect_to :root, danger: JSON.parse(e.message).map {|msg| t("proforma_errors.#{msg}", default: msg) }.join('<br>'), status: :see_other
  end

  def share
    if share_message.save
      redirect_to @collection, notice: t('.success_notice'), status: :see_other
    else
      redirect_to @collection, alert: share_message.errors.full_messages.join(', '), status: :see_other
    end
  end

  def view_shared
    render :show
  end

  def save_shared # rubocop:disable Metrics/AbcSize
    if @collection.users.include? current_user
      return redirect_to user_messages_path(current_user),
        alert: t('.errors.already_member'),
        status: :see_other
    end

    ActiveRecord::Base.transaction(requires_new: true) do
      @collection.users << current_user
      message = Message.received_by(current_user).find_by(action: :collection_shared, attachment: @collection)
      message.mark_as_deleted(current_user)
      message.save!
      redirect_to @collection, notice: t('.success_notice'), status: :see_other
    end
  end

  def leave
    if @collection.users.one?
      @collection.destroy
      redirect_to Collection, notice: t('common.notices.object_deleted', model: Collection.model_name.human), status: :see_other
    else
      @collection.users.delete(current_user)
      redirect_to Collection, notice: t('.left_successfully'), status: :see_other
    end
  end

  def toggle_favorite
    if current_user.favorite_collections.include? @collection
      current_user.favorite_collections.delete @collection
      flash_message = t('.favorite.removed')
    else
      current_user.favorite_collections << @collection
      flash_message = t('.favorite.added')
    end
    redirect_to @collection, notice: flash_message, status: :see_other
  end

  private

  def create_collection_with_task
    if @collection.save
      redirect_to @collection.tasks.first, notice: t('collections.create.success_notice'), status: :see_other
    else
      flash.now[:alert] = t('collections.create.error')
    end
  end

  def set_option
    @option = params[:option] || 'mine'
  end

  def share_message
    @share_message ||= Message.new(share_message_args)
  end

  def share_message_args
    {sender: current_user, recipient: User.find_by(email: params[:user]), action: :collection_shared, attachment: @collection}
  end

  def push_tasks
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

  def load_and_authorize_account_link
    @account_link = AccountLink.find(params[:account_link])
    authorize @account_link, :use?
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def collection_tasks_params
    %i[id rank _destroy]
  end

  def collection_params
    params.expect(collection: [:title, :task_ids, :visibility_level, :description,
                               {collection_tasks_attributes: [collection_tasks_params]}])
  end
end
