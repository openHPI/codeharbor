class LabelCategoriesController < ApplicationController
  load_and_authorize_resource
  before_action :set_label_category, only: [:show, :edit, :update, :destroy]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized for this action.'
  end
  # GET /label_categories
  # GET /label_categories.json
  def index
    @label_categories = LabelCategory.all
  end

  # GET /label_categories/1
  # GET /label_categories/1.json
  def show
  end

  # GET /label_categories/new
  def new
    @label_category = LabelCategory.new
  end

  # GET /label_categories/1/edit
  def edit
  end

  # POST /label_categories
  # POST /label_categories.json
  def create
    @label_category = LabelCategory.new(label_category_params)

    respond_to do |format|
      if @label_category.save
        format.html { redirect_to @label_category, notice: 'Label category was successfully created.' }
        format.json { render :show, status: :created, location: @label_category }
      else
        format.html { render :new }
        format.json { render json: @label_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /label_categories/1
  # PATCH/PUT /label_categories/1.json
  def update
    respond_to do |format|
      if @label_category.update(label_category_params)
        format.html { redirect_to @label_category, notice: 'Label category was successfully updated.' }
        format.json { render :show, status: :ok, location: @label_category }
      else
        format.html { render :edit }
        format.json { render json: @label_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /label_categories/1
  # DELETE /label_categories/1.json
  def destroy
    @label_category.destroy
    respond_to do |format|
      format.html { redirect_to label_categories_url, notice: 'Label category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_label_category
      @label_category = LabelCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def label_category_params
      params.require(:label_category).permit(:name)
    end
end
