class GroupsController < ApplicationController
  load_and_authorize_resource
  before_action :set_group, only: [:show, :edit, :update, :destroy, :request_access, :grant_access, :delete_from_group, :make_admin]
  before_action :set_option, only: [:index]
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.group.authorization')
  end
  # GET /groups
  # GET /groups.json
  def index
    if @option == 'mine'
      @groups = current_user.groups.paginate(per_page: 5, page: params[:page])
    else
      @groups = Group.all.paginate(per_page: 5, page: params[:page])
    end
  end

  def groups_all
    @groups = Group.all.paginate(per_page: 10, page: params[:page])
  end

  def search
    @groups = current_user.groups
    respond_to do |format|
      format.html
      format.json { render json: @groups.where('name ilike ?', "%#{params[:term]}%") }
    end
  end
  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        @group.add(current_user, as: 'admin')
        format.html { redirect_to @group, notice: t('controllers.group.created') }
        format.json { render :index, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: t('controllers.group.updated') }
        format.json { render :index, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: t('controllers.group.destroyed') }
      format.json { head :no_content }
    end
  end

  def leave
    last_admin = current_user.last_admin?(@group)
    if last_admin
      redirect_to @group, alert: t('controllers.group.leave.alert')
    else
      @group.users.delete(current_user)
      redirect_to groups_path, notice: t('controllers.group.leave.notice')
    end
  end
  def request_access
    flash[:notice] = t('controllers.group.request_access.notice')
    @group.admins.each do |admin|
      Message.create(sender: current_user, recipient: admin, text: t('controllers.group.request_access.text', user: current_user.name, group: @group.name), param_type: 'group', param_id: @group.id, sender_status: 'd')
      AccessRequest.send_access_request(current_user, admin, @group).deliver_now
    end
    @group.add_pending_user(current_user)
    redirect_to groups_path
  end

  def remove_exercise
    exercise = Exercise.find(params[:exercise])
    @group.exercises.delete(exercise)
    redirect_to @group, notice: t('controllers.group.remove_exercise_notice')
  end
  def grant_access
    user = User.find(params[:user])
    @group.grant_access(user)
    Message.create(sender: current_user, recipient: user, text: t('controllers.group.grant_access.text', user: current_user.name, group: @group.name), param_type: 'group_accepted', param_id: @group.id, sender_status: 'd')
    Message.where(sender: user, recipient:current_user, param_type: 'group', param_id: @group.id).delete_all
    redirect_to @group, notice: t('controllers.group.grant_access.notice')
  end

  def delete_from_group
    user = User.find(params[:user])
    @group.users.delete(user)
    redirect_to @group, notice: t('controllers.group.delete_from_group_notice')
  end

  def deny_access
    user = User.find(params[:user])
    @group.users.delete(user)
    Message.create(sender: current_user, recipient: user, text: t('controllers.group.deny_access.text', user: current_user.name, group: @group.name), param_type: 'group_declined', sender_status: 'd')
    Message.where(sender: user, recipient:current_user, param_type: 'group', param_id: @group.id).delete_all
    redirect_to @group, notice: t('controllers.group.deny_access.notice')
  end

  def make_admin
    user = User.find(params[:user])
    @group.make_admin(user)
    redirect_to @group, notice: t('controllers.group.make_admin_notice')
  end

  def add_account_link_to_member
    user = User.find(params[:user])
    account_link = AccountLink.find(params[:account_link])
    user.external_account_links << account_link
    redirect_to @group, notice: t('controllers.group.granted_push')
  end

  def remove_account_link_from_member
    user = User.find(params[:user])
    account_link = AccountLink.find(params[:account_link])
    user.external_account_links.delete(account_link)
    redirect_to @group, notice: t('controllers.group.removed_push')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_option
      if params[:option]
        @option = params[:option]
      else
        @option = 'mine'
      end
    end

    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :description)
    end
end
