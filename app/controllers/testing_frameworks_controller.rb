class TestingFrameworksController < ApplicationController
  before_action :set_testing_framework, only: [:show, :edit, :update, :destroy]

  # GET /testing_frameworks
  # GET /testing_frameworks.json
  def index
    @testing_frameworks = TestingFramework.all
  end

  # GET /testing_frameworks/1
  # GET /testing_frameworks/1.json
  def show
  end

  # GET /testing_frameworks/new
  def new
    @testing_framework = TestingFramework.new
  end

  # GET /testing_frameworks/1/edit
  def edit
  end

  # POST /testing_frameworks
  # POST /testing_frameworks.json
  def create
    @testing_framework = TestingFramework.new(testing_framework_params)

    respond_to do |format|
      if @testing_framework.save
        format.html { redirect_to @testing_framework, notice: 'Testing framework was successfully created.' }
        format.json { render :show, status: :created, location: @testing_framework }
      else
        format.html { render :new }
        format.json { render json: @testing_framework.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /testing_frameworks/1
  # PATCH/PUT /testing_frameworks/1.json
  def update
    respond_to do |format|
      if @testing_framework.update(testing_framework_params)
        format.html { redirect_to @testing_framework, notice: 'Testing framework was successfully updated.' }
        format.json { render :show, status: :ok, location: @testing_framework }
      else
        format.html { render :edit }
        format.json { render json: @testing_framework.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /testing_frameworks/1
  # DELETE /testing_frameworks/1.json
  def destroy
    @testing_framework.destroy
    respond_to do |format|
      format.html { redirect_to testing_frameworks_url, notice: 'Testing framework was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_testing_framework
      @testing_framework = TestingFramework.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def testing_framework_params
      params.require(:testing_framework).permit(:name)
    end
end
