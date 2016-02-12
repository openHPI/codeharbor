class ExecutionEnvironmentsController < ApplicationController
  before_action :set_execution_environment, only: [:show, :edit, :update, :destroy]

  # GET /execution_environments
  # GET /execution_environments.json
  def index
    @execution_environments = ExecutionEnvironment.all
  end

  # GET /execution_environments/1
  # GET /execution_environments/1.json
  def show
  end

  # GET /execution_environments/new
  def new
    @execution_environment = ExecutionEnvironment.new
  end

  # GET /execution_environments/1/edit
  def edit
  end

  # POST /execution_environments
  # POST /execution_environments.json
  def create
    @execution_environment = ExecutionEnvironment.new(execution_environment_params)

    respond_to do |format|
      if @execution_environment.save
        format.html { redirect_to @execution_environment, notice: 'Execution environment was successfully created.' }
        format.json { render :show, status: :created, location: @execution_environment }
      else
        format.html { render :new }
        format.json { render json: @execution_environment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /execution_environments/1
  # PATCH/PUT /execution_environments/1.json
  def update
    respond_to do |format|
      if @execution_environment.update(execution_environment_params)
        format.html { redirect_to @execution_environment, notice: 'Execution environment was successfully updated.' }
        format.json { render :show, status: :ok, location: @execution_environment }
      else
        format.html { render :edit }
        format.json { render json: @execution_environment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /execution_environments/1
  # DELETE /execution_environments/1.json
  def destroy
    @execution_environment.destroy
    respond_to do |format|
      format.html { redirect_to execution_environments_url, notice: 'Execution environment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_execution_environment
      @execution_environment = ExecutionEnvironment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def execution_environment_params
      params.require(:execution_environment).permit(:language, :version)
    end
end
