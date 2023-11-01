# frozen_string_literal: true

class GroupsController < ApplicationController
  load_and_authorize_resource
  before_action :set_group, only: %i[show edit update destroy request_access grant_access delete_from_group make_admin]
  before_action :set_option, only: [:index]
  before_action :set_user, only: %i[grant_access delete_from_group deny_access make_admin demote_admin]

  def index
    @groups = if @option == 'mine'
                current_user.groups.paginate(page: params[:page], per_page: per_page_param)
              else
                Group.all.paginate(page: params[:page], per_page: per_page_param)
              end
  end

  def show; end

  def new
    @group = Group.new
  end

  def edit; end

  def create
    @group = Group.new(group_params)
    @group.group_memberships << GroupMembership.new(user: current_user, role: :admin)
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
    redirect_to groups_url, notice: t('common.notices.object_deleted', model: Group.model_name.human)
  end

  def leave
    if @group.last_admin?(current_user)
      redirect_to @group, alert: t('.cannot_leave_alert')
    else
      @group.users.delete(current_user)
      redirect_to groups_path, notice: t('.success_notice')
    end
  end

  def request_access
    flash[:notice] = t('.success_notice')
    @group.admins.each do |admin|
      send_access_request_message(admin, @group)

      AccessRequestMailer.send_access_request(current_user, admin, @group).deliver_now
    end
    @group.add(current_user, role: :applicant)
    redirect_to groups_path
  end

  def remove_task
    task = Task.find(params[:task])
    @group.tasks.delete(task)
    redirect_to @group, notice: t('common.notices.object_removed', model: Task.model_name.human)
  end

  def grant_access
    @group.grant_access(@user)
    send_grant_access_messages(@user, @group)

    Message.where(sender: @user, recipient: current_user, param_type: 'group', param_id: @group.id).destroy_all
    redirect_to @group, notice: t('.success_notice')
  end

  def delete_from_group
    @group.users.delete(@user)
    redirect_to @group, notice: t('.success_notice')
  end

  def deny_access
    @group.users.delete(@user)
    send_deny_access_message(@user, @group)

    Message.where(sender: @user, recipient: current_user, param_type: 'group', param_id: @group.id).destroy_all
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

  def send_access_request_message(admin, group)
    Message.create(sender: current_user,
      recipient: admin,
      text: t('groups.send_access_request_message.message', user: current_user.name, group: group.name),
      param_type: 'group',
      param_id: group.id,
      sender_status: 'd')
  end

  def send_deny_access_message(user, group)
    Message.create(sender: current_user,
      recipient: user,
      text: t('groups.send_deny_access_message.message', user: current_user.name, group: group.name),
      param_type: 'group_declined',
      sender_status: 'd')
  end

  def send_grant_access_messages(user, group)
    Message.create(sender: current_user,
      recipient: user,
      text: t('groups.send_grant_access_messages.message', user: current_user.name, group: group.name),
      param_type: 'group_accepted',
      param_id: group.id,
      sender_status: 'd')
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_option
    @option = params[:option] || 'mine'
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user])
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def group_params
    params.require(:group).permit(:name, :description)
  end
end
