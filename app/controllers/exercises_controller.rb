require 'oauth2'

class ExercisesController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise, only: [:show, :edit, :update, :destroy, :add_to_cart, :add_to_collection, :push_external]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized for this exercise.'
  end
  # GET /exercises
  # GET /exercises.json
  def index
    if params[:private]
      @exercises = Exercise.search_private(params[:search]).sort{ |y,x| x.avg_rating <=> y.avg_rating }.paginate(per_page: 5, page: params[:page])
    else
      @exercises = Exercise.search_public(params[:search]).sort{ |y,x| x.avg_rating <=> y.avg_rating }.paginate(per_page: 5, page: params[:page])
    end
  end

  # GET /exercises/1
  # GET /exercises/1.json
  def show

    exercise_relation = ExerciseRelation.find_by(clone_id: @exercise.id)
    if exercise_relation
      @exercise_relation = exercise_relation
      @exercise_relation.origin = exercise_relation.origin
      @exercise_relation.clone = exercise_relation.clone
    end
    @files = ExerciseFile.where(exercise: @exercise)
    @tests = Test.where(exercise: @exercise)

  end

  # GET /exercises/new
  def new
    @exercise = Exercise.new
    @exercise.descriptions << Description.new
    @labels = []
    @form_action
  end


  def duplicate
    exercise_origin = Exercise.find(params[:id])
    @exercise = Exercise.new
    @exercise_relation = ExerciseRelation.new
    @exercise.private = exercise_origin.private
    @origin = exercise_origin

    exercise_origin.descriptions.each do |d|
      @exercise.descriptions << Description.new(d.attributes)
    end
    exercise_origin.tests.each do |t|
      @exercise.tests << Test.new(t.attributes)
    end
    exercise_origin.exercise_files.each do |f|
      @exercise.exercise_files << ExerciseFile.new(f.attributes)
    end
    render 'duplicate'
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

    if params[:exercise][:origin_id]
      @exercise_relation = ExerciseRelation.new
      @exercise_relation.clone = @exercise
      @exercise_relation.origin_id = params[:exercise][:origin_id]
      @exercise_relation.relation_id = params[:exercise][:id]
    end
    if params[:labels]
      params[:labels].each do |label|
        @label = Label.find_by(name: label)
        unless @label
          @label = Label.create(name: label, color: '006600', label_category: nil)
        end
        @exercise.labels << @label
      end
    end

    respond_to do |format|
      if @exercise_relation
        if @exercise_relation.save
          if @exercise.save
            format.html { redirect_to @exercise, notice: 'Exercise was successfully created.' }
            format.json { render :show, status: :created, location: @exercise }
          else
            format.html { render :new }
            format.json { render json: @exercise.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to duplicate_exercise_path(@exercise_relation.origin) }
          format.json { render json: @exercise.errors, status: :unprocessable_entity }
        end
      else
        if @exercise.save
          format.html { redirect_to @exercise, notice: 'Exercise was successfully created.' }
          format.json { render :show, status: :created, location: @exercise }
        else
          format.html { render :new }
          format.json { render json: @exercise.errors, status: :unprocessable_entity }
        end
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

  def add_label
    @labels << 1
  end

  def add_to_cart
    cart = Cart.find_by(user: current_user)
    if cart.add_exercise(@exercise)
      redirect_to @exercise, notice: 'Exercise was successfully added to your cart.'
    else
      redirect_to @exercise, alert: 'Exercise already in your cart.'
    end
  end

  def add_to_collection
    collection = Collection.find(params[:collection][:id])
    if collection.add_exercise(@exercise)
      redirect_to @exercise, notice: 'Exercise added to collection.'
    else
      redirect_to @exercise, alert: 'Exercise already in collection.'
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