require 'zip'

class CollectionsController < ApplicationController
  load_and_authorize_resource
  before_action :set_collection, only: [:show, :edit, :update, :destroy, :remove_exercise, :remove_all, :download_all, :share, :view_shared, :save_shared]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.collections.authorization')
  end
  # GET /collections
  # GET /collections.json
  def index
    @collections = Collection.where(user: current_user).paginate(per_page: 5, page: params[:page])
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections
  # POST /collections.json
  def create
    @collection = Collection.new(collection_params)
    @collection.user = current_user

    respond_to do |format|
      if @collection.save
        format.html { redirect_to collections_path(@collection), notice: t('controllers.collections.created')}
        format.json { render :index, status: :created, location: @collection }
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to collections_path, notice: t('controllers.collections.updated')}
        format.json { render :index, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_exercise
    if @collection.remove_exercise(params[:exercise])
      redirect_to @collection, notice: t('controllers.collections.remove_exercise_success')
    else
      redirect_to @collection, alert: t('controllers.collections.remove_exercise_fail')
    end
  end

  def remove_all
    if @collection.remove_all
      redirect_to @collection, notice: t('controllers.collections.remove_all_success')
    else
      redirect_to @collection, alert: t('controllers.collections.remove_all_fail')
    end
  end

  def download_all
    filename = "#{@collection.title}.zip"

    #This is the tricky part
    #Initialize the temp file as a zip file

    stringio = Zip::OutputStream.write_buffer do |zio|
      @collection.exercises.each do |exercise|
        zio.put_next_entry("#{exercise.title}.xml")
        zio.write exercise.to_proforma_xml
      end
    end
    binary_data = stringio.string

    send_data(binary_data, :type => 'application/zip', :filename => filename)

  end

  def share
    user = User.find_by(email: params[:user])
    text =  t('controllers.collections.share.text', user: current_user.name, collection: @collection.title)
    message = Message.new(sender: current_user, recipient: user, param_type: 'collection', param_id: @collection.id, text: text)
    if message.save
      redirect_to collection_path(@collection), notice: t('controllers.collections.share.notice')
    else
      redirect_to collection_path(@collection), alert: t('controllers.collections.share.alert')
    end
  end

  def view_shared
    @user = User.find(params[:user])
    render :show
  end

  def save_shared
    collection = @collection.dup
    collection.user = current_user
    @collection.exercises.each do |e|
      collection.exercises << e
    end

    if collection.save
      redirect_to collection_path(collection), notice:  t('controllers.collections.save_shared.notice')
    else
      redirect_to users_messages_path, alert:  t('controllers.collections.save_shared.alert')
    end
  end
  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: t('controllers.collections.destroyed')}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_params
      params.require(:collection).permit(:title)
    end
end
