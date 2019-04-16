# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_user
  before_action :set_message, only: %i[show edit update destroy add_author delete]
  before_action :set_option, only: [:index]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.message.authorization')
  end

  # GET /messages
  # GET /messages.json
  def index
    if @option == 'inbox'
      @messages = Message.where(recipient: current_user)
                         .where('recipient_status != ?', 'd')
                         .order(created_at: :desc)
                         .paginate(per_page: 5, page: params[:page])
      @messages.each do |message|
        message.recipient_status = 'r'
        message.save
      end
    else
      @messages = Message.where(sender: current_user)
                         .where('sender_status != ?', 'd')
                         .order(created_at: :desc)
                         .paginate(per_page: 5, page: params[:page])
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show; end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit; end

  # POST /messages
  # POST /messages.json
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

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
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

  # DELETE /messages/1
  # DELETE /messages/1.json
  def delete
    if @message.sender == current_user
      @message.sender_status = 'd'
      @message.delete if @message.recipient_status == 'd'
    else
      @message.recipient_status = 'd'
      @message.delete if @message.sender_status == 'd'
    end

    option = params[:option]

    if @message.save
      redirect_to user_messages_path(@user, option: option), notice: t('controllers.message.deleted_notice')
    else
      redirect_to user_messages_path(@user, option: option), alert: t('controllers.message.deleted_alert')
    end
  end

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
