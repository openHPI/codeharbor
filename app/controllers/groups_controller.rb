# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :load_and_authorize_group, except: %i[index new create]
  before_action :set_option, only: [:index]
  before_action :set_user, only: %i[grant_access delete_from_group deny_access make_admin demote_admin]

  def index
    groups = @option == 'mine' ? current_user.groups : Group.all

    @groups = groups
      .paginate(page: params[:page], per_page: per_page_param)
      .includes(group_memberships: [:user])
      .load
    authorize @groups
  end

  def show; end

  def new
    @group = Group.new
    authorize @group
  end

  def edit; end

  def create
    @group = Group.new(group_params)
    @group.group_memberships << GroupMembership.new(user: current_user, role: :admin)
    authorize @group

    if @group.save
      redirect_to @group, notice: t('common.notices.object_created', model: Group.model_name.human)
    else
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: t('common.notices.object_updated', model: Group.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to Group, notice: t('common.notices.object_deleted', model: Group.model_name.human)
  end

  def leave
    if @group.last_admin?(current_user)
      redirect_to @group, alert: t('.cannot_leave_alert')
    else
      @group.users.delete(current_user)
      redirect_to Group, notice: t('.success_notice')
    end
  end

  def request_access
    flash[:notice] = t('.success_notice')
    @group.admins.each do |admin|
      send_message(admin, :group_request)

      AccessRequestMailer.send_access_request(current_user, admin, @group).deliver_later
    end
    @group.add(current_user, role: :applicant)
    redirect_to Group
  end

  def remove_task
    task = Task.find(params[:task])
    @group.tasks.delete(task)
    redirect_to @group, notice: t('common.notices.object_removed', model: Task.model_name.human)
  end

  def grant_access
    @group.grant_access(@user)
    send_message(@user, :group_approval)

    @group.messages.where(sender: @user, recipient: current_user, action: :group_request).destroy_all
    redirect_to @group, notice: t('.success_notice')
  end

  def delete_from_group
    @group.users.delete(@user)
    redirect_to @group, notice: t('.success_notice')
  end

  def deny_access
    @group.users.delete(@user)
    send_message(@user, :group_rejection)

    @group.messages.where(sender: @user, recipient: current_user, action: :group_request).destroy_all
    redirect_to @group, notice: t('.success_notice')
  end

  def make_admin
    @group.make_admin(@user)
    redirect_to @group, notice: t('.success_notice')
  end

  def demote_admin
    @group.demote_admin(@user)
    redirect_to @group, notice: t('.success_notice')
  end

  private

  # action is one of [:group_request, :group_approval, :group_rejection]
  def send_message(recipient, action)
    Message.create(sender: current_user,
      recipient:,
      action:,
      attachment: @group,
      sender_status: :deleted)
  end

  def set_option
    @option = params[:option] || 'mine'
  end

  def load_and_authorize_group
    @group = Group.find(params[:id])
    authorize @group
  end

  def set_user
    @user = User.find(params[:user])
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def group_params
    params.expect(group: %i[name description])
  end
end
