require 'oauth2'

class ExercisesController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise, only: [:show, :edit, :update, :destroy, :add_to_cart, :add_to_collection, :push_external, :contribute]
  before_action :set_option, only: [:index]
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized for this exercise.'
  end
  # GET /exercises
  # GET /exercises.json
  def index
    @exercises = Exercise.search(params[:search],@option,current_user).sort{ |y,x| x.avg_rating <=> y.avg_rating }.paginate(per_page: 5, page: params[:page])
  end

  # GET /exercises/1
  # GET /exercises/1.json
  def show

    exercise_relation = ExerciseRelation.find_by(clone_id: @exercise.id)
    if exercise_relation
      @exercise_relation = exercise_relation
    end
    if @exercise.ratings
      user_rating = @exercise.ratings.find_by(user: current_user)
      if user_rating
        @user_rating = user_rating.rating
      end
    end

    @files = ExerciseFile.where(exercise: @exercise)
    @tests = Test.where(exercise: @exercise)

  end

  # GET /exercises/new
  def new
    @exercise = Exercise.new
    @exercise.descriptions << Description.new
    @form_action
  end


  def duplicate

    @exercise = Exercise.new
    @exercise_relation = ExerciseRelation.new

    exercise_origin = Exercise.find(params[:id])
    @exercise.private = exercise_origin.private
    @exercise_relation.origin = exercise_origin
    @exercise.errors[:base] = params[:errors].inspect if params[:errors]

    exercise_origin.descriptions.each do |d|
      @exercise.descriptions << Description.new(d.attributes)
    end
    exercise_origin.tests.each do |t|
      @exercise.tests << Test.new(t.attributes)
    end
    exercise_origin.exercise_files.each do |f|
      @exercise.exercise_files << ExerciseFile.new(f.attributes)
    end
    @form_action
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
    exercise_dependencies

    respond_to do |format|
      if @exercise.save
        format.html { redirect_to @exercise, notice: 'Exercise was successfully created.' }
        format.json { render :show, status: :created, location: @exercise }
      else
        if !@exercise_relation
          format.html { render :new }
        else
          puts(@exercise.errors.inspect)
          format.html { render :duplicate}
        end
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
    cart = Cart.find_by(user: current_user)
    if cart.add_exercise(@exercise)
      redirect_to @exercise, notice: 'Exercise was successfully added to your cart.'
    else
      redirect_to @exercise, alert: 'Exercise already in your cart.'
    end
  end

  def add_to_collection
    collection = Collection.find(params[:collection])
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
    account_link = AccountLink.find(params[:account_link])
    oauth2Client = OAuth2::Client.new('client_id', 'client_secret', :site => account_link.push_url)
    oauth2_token = account_link[:oauth2_token]
    token = OAuth2::AccessToken.from_hash(oauth2Client, :access_token => oauth2_token)
    logger.fatal('@exercise.to_proforma_xml')
    logger.fatal(@exercise.to_proforma_xml)
    logger.fatal('@exercise.to_proforma_xml')
    token.post(account_link.push_url, {body: @exercise.to_proforma_xml})
    redirect_to @exercise, notice: ('Exercise pushed to ' + account_link.readable)
  end

  def download_exercise
    xsd = Nokogiri::XML::Schema(File.read('app/assets/taskxml.xsd'))
    doc = Nokogiri::XML(@exercise.to_proforma_xml)

    errors = xsd.validate(doc)

    if errors.any?
      errors.each do |error|
        puts error.message
      end
      redirect_to @exercise, alert: ('An error occurred. Please contact an admin!')
    else
      send_data doc, filename: "#{@exercise.title}.xml", type: "application/xml"
    end
  end

  def import_exercise

    xsd = Nokogiri::XML::Schema(File.read('app/assets/taskxml.xsd'))
    doc = Nokogiri::XML(params[:xml])

    errors = xsd.validate(doc)

    if errors.any?
      errors.each do |error|
        puts error.message
      end
      flash[:alert] = "Your xml file is not valid"
      render :nothing => true, :status => 200
    else
      @exercise = Exercise.new
      @exercise.user = current_user
      @exercise.import_xml(doc)

      if @exercise.save
        flash[:notice] = 'Exercise successfully imported!'
        redirect_to edit_exercise_path(@exercise.id)
      else
        flash[:alert] = "Cannot import your xml file"
        redirect_to exercises_path
      end
    end
  end

  def contribute
    author = @exercise.user
    AccessRequest.send_contribution_request(author, @exercise, current_user).deliver_later
    text = "#{current_user.name} wants to contribute to your Exercise #{@exercise.title}."
    Message.create(sender: current_user, recipient: author, param_type: 'exercise', param_id: @exercise.id, text: text)
      redirect_to exercises_path, notice: "Your request has been sent."
  end

  private

  def exercise_dependencies
    if params[:exercise][:exercise_relation]
      @exercise_relation = ExerciseRelation.new
      @exercise_relation.clone = @exercise
      @exercise_relation.origin_id = params[:exercise][:exercise_relation][:origin_id]
      @exercise_relation.relation_id = params[:exercise][:exercise_relation][:relation_id]
      @exercise_relation.save
    end

    if params[:exercise][:groups]
      params[:exercise][:groups].delete_at(0)
      params[:exercise][:groups].each do |array|
        group = Group.find(array)
        group.add(@exercise)
      end
    end

  end
  def set_option
    if params[:option]
      @option = params[:option]
    else
      @option = 'mine'
    end
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def exercise_params
    params.require(:exercise).permit(:title, :description, :maxrating, :private, :execution_environment_id)
  end
end