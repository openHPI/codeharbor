class FileTypesController < ApplicationController
  load_and_authorize_resource
  before_action :set_file_type, only: [:show, :edit, :update, :destroy]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.file_type.authorization')
  end

  def search
    @file_types = FileType.all
    respond_to do |format|
      format.html
      format.json { render json: @file_types.where('type ilike ?', "%#{params[:term]}%") }
    end
  end
  # GET /file_types
  # GET /file_types.json
  def index
    @file_types = FileType.all.paginate(per_page: 10, page: params[:page])
  end

  # GET /file_types/1
  # GET /file_types/1.json
  def show
  end

  # GET /file_types/new
  def new
    @file_type = FileType.new
  end

  # GET /file_types/1/edit
  def edit
  end

  # POST /file_types
  # POST /file_types.json
  def create
    @file_type = FileType.new(file_type_params)

    respond_to do |format|
      if @file_type.save
        format.html { redirect_to @file_type, notice: t('controllers.file_type.created')}
        format.json { render :show, status: :created, location: @file_type }
      else
        format.html { render :new }
        format.json { render json: @file_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /file_types/1
  # PATCH/PUT /file_types/1.json
  def update
    respond_to do |format|
      if @file_type.update(file_type_params)
        format.html { redirect_to @file_type, notice: t('controllers.file_type.updated') }
        format.json { render :show, status: :ok, location: @file_type }
      else
        format.html { render :edit }
        format.json { render json: @file_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /file_types/1
  # DELETE /file_types/1.json
  def destroy
    @file_type.destroy
    respond_to do |format|
      format.html { redirect_to file_types_url, notice: t('controllers.file_type.destroyed')}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_file_type
      @file_type = FileType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def file_type_params
      params[:file_type].permit(:name, :file_extension)
    end
end
