require 'oauth2'

class ExercisesController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise, only: [:show, :edit, :update, :destroy, :push_external]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized for this exercise.'
  end
  # GET /exercises
  # GET /exercises.json
  def index
    @exercises = Exercise.search(params[:search]).sort{ |y,x| x.avg_rating <=> y.avg_rating }.paginate(per_page: 5, page: params[:page])
  end

  # GET /exercises/1
  # GET /exercises/1.json
  def show
    @files = ExerciseFile.where(exercise: @exercise)
    @tests = Test.where(exercise: @exercise)

  end

  # GET /exercises/new
  def new
    @exercise = Exercise.new
    @exercise.descriptions << Description.new
  end

  # GET /exercises/1/edit
  def edit
  end

  # POST /exercises
  # POST /exercises.json
  def create
    @exercise = Exercise.new(exercise_params)
    @exercise.add_descriptions(params[:exercise][:descriptions_attributes])
    respond_to do |format|
      if @exercise.save
        format.html { redirect_to @exercise, notice: 'Exercise was successfully created.' }
        format.json { render :show, status: :created, location: @exercise }
      else
        format.html { render :new }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exercises/1
  # PATCH/PUT /exercises/1.json
  def update
    @exercise.exercise_files.each do |file|
      file.update(file_params(file))
    end
    @exercise.tests.each do |test|
      test.update(test_params(test))
    end
    @exercise.add_descriptions(params[:exercise][:descriptions_attributes])
    respond_to do |format|
      if @exercise.update(exercise_params)
        format.html { redirect_to @exercise, notice: 'Exercise was successfully updated.' }
        format.json { render :show, status: :ok, location: @exercise }
      else
        format.html { render :edit }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exercises/1
  # DELETE /exercises/1.json
  def destroy
    @exercise.destroy
    respond_to do |format|
      format.html { redirect_to exercises_url, notice: 'Exercise was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def exercises_all
    @exercises = Exercise.all
  end

  def push_external
    #account_link = AccountLink.find(params[:account_link][:id]);
    #oauth2Client = OAuth2::Client.new('client_id', 'client_secret', :site => account_link.push_url)
    #oauth2_token = account_link[:oauth2_token]
    #token = OAuth2::AccessToken.from_hash(oauth2Client, :access_token => oauth2_token)
    #token.post(account_link.push_url)
    #redirect_to @exercise, notice: ('Exercise pushed to ' + account_link.readable)
    redirect_to @exercise, notice: 'Exercise was successfully exported.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exercise
      @exercise = Exercise.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exercise_params
      params.require(:exercise).permit(:title, :description, :maxrating, :public)
    end

    def file_params(file)
      params.require(file.id.to_s).permit(:main, :content, :path, :solution, :filetype)
    end

    def test_params(test)
      params.require('test_'+test.id.to_s).permit(:content, :feedback_message, :testing_framework_id)
    end
end
