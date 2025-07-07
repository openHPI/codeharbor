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

  def create
    recipient = params.require(:message).delete(:recipient)
    @message = Message.new(message_params)
    @message.sender = current_user
    @message.recipient = User.find_by(email: recipient) if recipient.present?
    authorize @message

    if @message.save
      redirect_to user_messages_path(@user), notice: t('.sent_successfully'), status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    @message.mark_as_deleted(current_user)

    if @message.save
      redirect_to user_messages_path(@user, option: params[:option]),
        notice: t('common.notices.object_deleted', model: Message.model_name.human), status: :see_other
    else
      redirect_to user_messages_path(@user, option: params[:option]), alert: t('.error'), status: :see_other
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
    params.expect(message: %i[text sender_id recipient_id sender_status recipient_status])
  end
end
