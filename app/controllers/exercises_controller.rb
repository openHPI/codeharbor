require 'oauth2'

class ExercisesController < ApplicationController
  load_and_authorize_resource :except => [:import_proforma_xml]
  before_action :set_exercise, only: [:show, :edit, :update, :destroy, :add_to_cart, :add_to_collection, :push_external, :contribute]
  before_action :set_search, only: [:index]
  skip_before_filter :verify_authenticity_token, only: [:import_proforma_xml]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.exercise.authorization')
  end
  # GET /exercises
  # GET /exercises.json
  def index
    if @order == 'order_created'
      @exercises = Exercise.search(params[:search],params[:settings],@option,current_user).sort{ |y,x| x.created_at <=> y.created_at }.paginate(per_page: 5, page: params[:page])
    else
      @exercises = Exercise.search(params[:search],params[:settings],@option,current_user).sort{ |y,x| x.average_rating <=> y.average_rating }.paginate(per_page: 5, page: params[:page])
    end
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
    exercise_relation = ExerciseRelation.find_by(clone_id: params[:id])
    if exercise_relation
      @exercise_relation = exercise_relation
    end
  end

  # POST /exercises
  # POST /exercises.json
  def create
    @exercise = Exercise.new(exercise_params)
    @exercise.add_attributes(params[:exercise])
    @exercise.user = current_user

    respond_to do |format|
      if @exercise.save
        format.html { redirect_to @exercise, notice: t('controllers.exercise.created') }
        format.json { render :show, status: :created, location: @exercise }
      else
        if !params[:exercise][:exercise_relation] #Exercise Relation is set if form is for duplicate exercise, otherwise it's not.
          format.html { render :new }
        else
          puts(@exercise.errors.inspect)
          format.html { redirect_to duplicate_exercise_path(params[:exercise][:exercise_relation][:origin_id])}
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
        format.html { redirect_to @exercise, notice: t('controllers.exercise.updated')  }
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
      format.html { redirect_to exercises_url, notice: t('controllers.exercise.destroyed') }
      format.json { head :no_content }
    end
  end

  def add_to_cart
    cart = Cart.find_by(user: current_user)
    if cart.add_exercise(@exercise)
      redirect_to @exercise, notice: t('controllers.exercise.add_to_cart_success')
    else
      redirect_to @exercise, alert: t('controllers.exercise.add_to_cart_fail')
    end
  end

  def add_to_collection
    collection = Collection.find(params[:collection])
    if collection.add_exercise(@exercise)
      redirect_to @exercise, notice: t('controllers.exercise.add_to_collection_success')
    else
      redirect_to @exercise, alert: t('controllers.exercise.add_to_collection_fail')
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
    token.post(account_link.push_url, {body: @exercise.to_proforma_xml})
    redirect_to @exercise, notice: t('controllers.exercise.push_external_notice', account_link: account_link.readable)
  end

  def download_exercise
    xsd = Nokogiri::XML::Schema(File.read('app/assets/taskxml.xsd'))
    doc = Nokogiri::XML(@exercise.to_proforma_xml)

    errors = xsd.validate(doc)

    title = @exercise.title
    title = title.tr('.,:*|"<>/\\', '')
    title = title.gsub /[ (){}\[\]]/, '_'

    if errors.any?
      errors.each do |error|
        puts error.message
      end
      redirect_to @exercise, alert: t('controllers.exercise.download_error')
    else
      downloads_new = @exercise.downloads+1
      @exercise.update(downloads: downloads_new)
      send_data doc, filename: "#{title}.xml", type: "application/xml"
    end
  end

  def import_proforma_xml
    begin
      user = user_for_oauth2_request()
      exercise = Exercise.new
      request_body = request.body.read
      doc = Nokogiri::XML(request_body)
      logger.fatal(doc.inspect)
      exercise.import_xml(doc)
      exercise.user = user
      saved = exercise.save
      if saved
        render :text => t('controllers.exercise.import_proforma_xml.success'), :status => 200
      else
        logger.info(exercise.errors.full_messages)
        render :text => t('controllers.exercise.import_proforma_xml.invalid'), :status => 400
      end
    rescue => error
      if error.class == Hash
        render :text => error.message, :status => error.status
      else
        raise error
        render :text => '', :status => 500
      end
    end
  end

  def user_for_oauth2_request
    authorizationHeader = request.headers['Authorization']
    if authorizationHeader == nil
      raise ({status: 401, message: t('controllers.exercise.import_proforma_xml.no_header')})
    end

    oauth2Token = authorizationHeader.split(' ')[1]
    if oauth2Token == nil || oauth2Token.size == 0
      raise ({status: 401, message: t('controllers.exercise.import_proforma_xml.no_token')})
    end

    user = user_by_code_harbor_token(oauth2Token)
    if user == nil
      raise ({status: 401, message: t('controllers.exercise.import_proforma_xml.unknown_token')})
    end

    return user
  end
  private :user_for_oauth2_request

  def user_by_code_harbor_token(oauth2Token)
    link = AccountLink.where(:oauth2_token => oauth2Token)[0]
    if link != nil
      return link.user
    end
  end
  private :user_by_code_harbor_token

  def import_exercise

    xsd = Nokogiri::XML::Schema(File.read('app/assets/taskxml.xsd'))
    doc = Nokogiri::XML(params[:xml])

    errors = xsd.validate(doc)

    if errors.any?
      errors.each do |error|
        puts error.message
      end
      flash[:alert] = t('controllers.exercise.xml_not_valid')
      render :nothing => true, :status => 200
    else
      @exercise = Exercise.new
      @exercise.user = current_user
      @exercise.import_xml(doc)

      if @exercise.save
        flash[:notice] = t('controllers.exercise.import_success')
        redirect_to edit_exercise_path(@exercise.id)
      else
        flash[:alert] = t('controllers.exercise.import_fail')
        redirect_to exercises_path
      end
    end
  end

  def contribute
    author = @exercise.user
    AccessRequest.send_contribution_request(author, @exercise, current_user).deliver_later
    text = t('controllers.exercise.contribute', user: current_user.name, exercise: @exercise.title)
    Message.create(sender: current_user, recipient: author, param_type: 'exercise', param_id: @exercise.id, text: text, sender_status: 'd')
    redirect_to exercises_path, notice: t('controllers.exercise.contribute_notice')
  end

  def add_author
    user = User.find(params[:user])
    ExerciseAuthor.create(user: user, exercise: @exercise)
    text = t('controllers.exercise.add_author_text', user: current_user.name, exercise: @exercise.title)
    Message.create(sender: current_user, recipient: user, param_type: 'exercise_accepted', param_id: @exercise.id, text: text, sender_status: 'd')
    Message.where(sender: user, recipient:current_user, param_type: 'exercise', param_id: @exercise.id).delete_all
    redirect_to user_messages_path(current_user), notice: t('controllers.exercise.add_author_notice')
  end

  def decline_author
    user = User.find(params[:user])
    text = t('controllers.exercise.decline_author_text', user: current_user.name, exercise: @exercise.title)
    Message.create(sender: current_user, recipient: user, param_type: 'exercise_declined', text: text, sender_status: 'd')
    Message.where(sender: user, recipient:current_user, param_type: 'exercise', param_id: @exercise.id).delete_all
    redirect_to user_messages_path(current_user), notice: t('controllers.exercise.decline_author_notice')
  end

  def report
    report = Report.find_by(user: current_user, exercise: @exercise)
    if report
      redirect_to exercise_path(@exercise), alert: t('controllers.exercise.report_alert')
    else
      Report.create(user: current_user, exercise: @exercise, text: params[:text])
      if @exercise.reports == 1
        Message.create(recipient: @exercise.user, param_type: 'report', param_id: @exercise.id, text: text, sender_status: 'd')
        @exercise.exercise_authors.each do |author|
          Message.create(recipient: author, param_type: 'report', param_id: @exercise.id, text: text, sender_status: 'd')
        end
        #Insert message for "Revision Board" here
      end
      redirect_to exercise_path(@exercise), notice: t('controllers.exercise.report_notice')
    end
  end
  private

  def set_search
    if params[:option]
      @option = params[:option]
    else
      @option = 'mine'
    end

    if params[:order_param]
      @order = params[:order_param]
    else
      @order = 'order_rating'
    end

    if params[:window]
      @dropdown = params[:window]
    else
      @dropdown = false
    end

    if params[:settings]
      @stars = params[:settings][:stars]
    else
      @stars = "0"
    end

    if params[:settings]
      @languages = params[:settings][:language]
    end

    if params[:settings]
      @proglanguages = params[:settings][:proglanguage]
    end

    if params[:settings]
      @created = params[:settings][:created]
    else
      @created = "0"
    end


  end
  # Use callbacks to share common setup or constraints between actions.
  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def exercise_params
    params.require(:exercise).permit(:title, :description, :maxrating, :private, :execution_environment_id, :license_id)
  end
end