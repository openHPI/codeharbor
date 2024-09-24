# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :load_and_authorize_message, only: %i[destroy]
  before_action :load_and_authorize_user
  before_action :set_option, only: %i[index]

  def index # rubocop:disable Metrics/AbcSize
    if @option == 'inbox'
      @messages = Message.received_by(current_user)
        .order(created_at: :desc)
        .paginate(page: params[:page], per_page: per_page_param)
      authorize @messages
      mark_messages_as_read @messages
    else
      @messages = Message.sent_by(current_user)
        .order(created_at: :desc)
        .paginate(page: params[:page], per_page: per_page_param)
      authorize @messages
    end
  end

  def new
    @message = Message.new
    authorize @message
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @message = Message.new(message_params)
    @message.sender = current_user
    @message.recipient = if params[:message][:recipient]
                           User.find_by(email: params[:message][:recipient])
                         else
                           User.find(params[:message][:recipient_hidden])
                         end
    authorize @message

    if @message.save
      redirect_to user_messages_path(@user), notice: t('.sent_successfully')
    else
      render :new
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    @message.mark_as_deleted(current_user)

    if @message.save
      redirect_to user_messages_path(@user, option: params[:option]),
        notice: t('common.notices.object_deleted', model: Message.model_name.human)
    else
      redirect_to user_messages_path(@user, option: params[:option]), alert: t('.error')
    end
  end

  def reply
    @recipient = User.find(params[:recipient])
    @message = Message.new(recipient: @recipient)
    authorize @message

    render :reply
  end

  private

  def mark_messages_as_read(messages)
    messages.each(&:recipient_status_read!)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_option
    @option = params[:option] || 'inbox'
  end

  def load_and_authorize_message
    @message = Message.find(params[:id])
    authorize @message
  end

  def load_and_authorize_user
    @user = User.find(params[:user_id])
    authorize @user, :show?
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def message_params
    params.require(:message).permit(:text, :sender_id, :recipient_id, :sender_status, :recipient_status)
  end
end
