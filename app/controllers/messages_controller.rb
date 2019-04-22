# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_user
  before_action :set_message, only: %i[show edit update destroy delete]
  before_action :set_option, only: [:index]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.message.authorization')
  end

  def index
    if @option == 'inbox'
      @messages = Message.received_by(current_user)
                         .order(created_at: :desc)
                         .paginate(per_page: 5, page: params[:page])
      mark_messages_as_read @messages
    else
      @messages = Message.sent_by(current_user)
                         .order(created_at: :desc)
                         .paginate(per_page: 5, page: params[:page])
    end
  end

  def show; end

  def new
    @message = Message.new
  end

  def edit; end

  # rubocop:disable Metrics/AbcSize
  def create
    @message = Message.new(message_params)
    @message.recipient_status = 'u'
    @message.sender = current_user
    @message.recipient = if params[:message][:recipient]
                           User.find_by(email: params[:message][:recipient])
                         else
                           User.find(params[:message][:recipient_hidden])
                         end

    respond_to do |format|
      if @message.save
        format.html { redirect_to user_messages_path(@user), notice: t('controllers.message.created') }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: t('controllers.message.updated') }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def delete
    if @message.sender == current_user
      @message.sender_status = 'd'
      @message.delete if @message.deleted_by_recipient?
    else
      @message.recipient_status = 'd'
      @message.delete if @message.deleted_by_sender?
    end

    option = params[:option]

    if @message.save
      redirect_to user_messages_path(@user, option: option), notice: t('controllers.message.deleted_notice')
    else
      redirect_to user_messages_path(@user, option: option), alert: t('controllers.message.deleted_alert')
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to user_messages_path, notice: t('controllers.message.destroyed') }
      format.json { head :no_content }
    end
  end

  def reply
    @recipient = User.find(params[:recipient])
    @message = Message.new
    render :reply
  end

  private

  def mark_messages_as_read(messages)
    messages.each do |message|
      message.recipient_status = 'r'
      message.save
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_option
    @option = params[:option] || 'inbox'
  end

  def set_message
    @message = Message.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def message_params
    params.require(:message).permit(:text, :sender_id, :recipient_id, :sender_status, :recipient_status)
  end
end
