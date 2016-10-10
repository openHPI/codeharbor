require 'oauth2'

class ExercisesController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise, only: [:show, :edit, :update, :destroy, :add_to_cart,:push_external]

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

  def duplicate
    exercise = Exercise.find(params[:id])
    @exercise = Exercise.new
    @exercise.title = exercise.title
    @exercise.private = exercise.private
    exercise.descriptions.each do |d|
      @exercise.descriptions << Description.new(d.attributes)
    end
    exercise.tests.each do |t|
      @exercise.tests << Test.new(t.attributes)
    end
    exercise.exercise_files.each do |f|
      @exercise.exercise_files << ExerciseFile.new(f.attributes)
    end
    render 'new'
  end

  # GET /exercises/1/edit
  def edit
  end

  # POST /exercises
  # POST /exercises.json
  def create
    @exercise = Exercise.new(exercise_params)
    @exercise.add_attributes(params[:exercise])
    @exercise.user = current_user
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
    @exercise.add_attributes(params[:exercise])
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

  def add_to_cart
    unless current_user.cart
      Cart.create(user: current_user)
    end
    cart = Cart.find_by(user: current_user)
    unless cart.exercises.find_by(id: @exercise.id)
      cart.exercises << @exercise
      redirect_to @exercise, notice: 'Exercise was successfully added to your cart.'
    else
      redirect_to @exercise, alert: 'Exercise already in your cart.'
    end
  end

  def exercises_all
    @exercises = Exercise.all
  end

  def push_external
    account_link = AccountLink.find(params[:account_link][:id]);
    oauth2Client = OAuth2::Client.new('client_id', 'client_secret', :site => account_link.push_url)
    oauth2_token = account_link[:oauth2_token]
    token = OAuth2::AccessToken.from_hash(oauth2Client, :access_token => oauth2_token)
    logger.fatal('@exercise.to_proforma_xml')
    logger.fatal(@exercise.to_proforma_xml)
    logger.fatal('@exercise.to_proforma_xml')
    token.post(account_link.push_url, {body: @exercise.to_proforma_xml})
    redirect_to @exercise, notice: ('Exercise pushed to ' + account_link.readable)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exercise
      @exercise = Exercise.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exercise_params
      params.require(:exercise).permit(:title, :description, :maxrating, :private, :execution_environment_id)
    end
end
