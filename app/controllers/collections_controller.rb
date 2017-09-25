class CollectionsController < ApplicationController
  load_and_authorize_resource
  before_action :set_collection, only: [:show, :edit, :update, :destroy, :remove_exercise, :remove_all, :download_all]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized to for this action.'
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
        format.html { redirect_to collections_path, notice: 'Collection was successfully created.' }
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
        format.html { redirect_to collections_path, notice: 'Collection was successfully updated.' }
        format.json { render :index, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_exercise
    if @collection.remove_exercise(params[:exercise])
      redirect_to @collection, notice: 'Exercise was successfully removed.'
    else
      redirect_to @collection, alert: 'You cannot remove this exercise.'
    end
  end

  def remove_all
    if @collection.remove_all
      redirect_to @collection, notice: 'All Exercises were successfully removed'
    else
      redirect_to @collection, alert: 'You cannot remove all exercises'
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

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
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
