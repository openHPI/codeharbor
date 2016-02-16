class ExerciseFilesController < ApplicationController
  before_action :set_exercise_file, only: [:show, :edit, :update, :destroy]

  # GET /exercise_files
  # GET /exercise_files.json
  def index
    @exercise_files = ExerciseFile.all
  end

  # GET /exercise_files/1
  # GET /exercise_files/1.json
  def show
  end

  # GET /exercise_files/new
  def new
    @exercise_file = ExerciseFile.new
  end

  # GET /exercise_files/1/edit
  def edit
  end

  # POST /exercise_files
  # POST /exercise_files.json
  def create
    @exercise_file = ExerciseFile.new(exercise_file_params)

    respond_to do |format|
      if @exercise_file.save
        format.html { redirect_to @exercise_file, notice: 'Exercise file was successfully created.' }
        format.json { render :show, status: :created, location: @exercise_file }
      else
        format.html { render :new }
        format.json { render json: @exercise_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exercise_files/1
  # PATCH/PUT /exercise_files/1.json
  def update
    respond_to do |format|
      if @exercise_file.update(exercise_file_params)
        format.html { redirect_to @exercise_file, notice: 'Exercise file was successfully updated.' }
        format.json { render :show, status: :ok, location: @exercise_file }
      else
        format.html { render :edit }
        format.json { render json: @exercise_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exercise_files/1
  # DELETE /exercise_files/1.json
  def destroy
    @exercise_file.destroy
    respond_to do |format|
      format.html { redirect_to exercise_files_url, notice: 'Exercise file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exercise_file
      @exercise_file = ExerciseFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exercise_file_params
      params.require(:exercise_file).permit(:main, :content, :path, :solution, :file_extension, :exercise_id, :purpose, :visibility, :name)
    end
end
