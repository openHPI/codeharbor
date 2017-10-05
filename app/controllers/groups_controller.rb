class GroupsController < ApplicationController
  load_and_authorize_resource
  before_action :set_group, only: [:show, :edit, :update, :destroy, :request_access, :grant_access, :delete_from_group, :make_admin]
  before_action :set_option, only: [:index]
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized to for this action.'
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
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
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
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
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
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def leave
    last_admin = current_user.last_admin?(@group)
    if last_admin
      redirect_to @group, alert: "You have to name somebody else admin first"
    else
      @group.users.delete(current_user)
      redirect_to groups_path, notice: "You successfully left the group"
    end
  end
  def request_access
    flash[:notice] = "Your Access request has been sent."
    @group.admins.each do |admin|
      AccessRequest.send_access_request(current_user, admin, @group).deliver_now
    end
    @group.add_pending_user(current_user)
    redirect_to groups_path
  end

  def remove_exercise
    exercise = Exercise.find(params[:exercise])
    @group.exercises.delete(exercise)
    redirect_to @group, notice: 'Exercise successfully removed'
  end
  def grant_access
    user = User.find(params[:user])
    @group.grant_access(user)
    redirect_to @group, notice: 'Access granted.'
  end

  def delete_from_group
    user = User.find(params[:user])
    @group.users.delete(user)
    redirect_to @group, notice: 'User deleted.'
  end

  def make_admin
    user = User.find(params[:user])
    @group.make_admin(user)
    redirect_to @group, notice: 'Made user to admin.'
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
