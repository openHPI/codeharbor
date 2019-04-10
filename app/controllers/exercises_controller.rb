require 'oauth2'
require 'proforma/importer'
require 'proforma/xml_generator'
require 'proforma/zip_importer'
require 'zip'

class ExercisesController < ApplicationController
  load_and_authorize_resource :except => [:import_proforma_xml]
  before_action :set_exercise, only: [:show, :edit, :update, :destroy, :add_to_cart, :add_to_collection, :push_external, :contribute]
  before_action :set_search, only: [:index]
  before_action :handle_search_params, only: :index
  skip_before_action :verify_authenticity_token, only: [:import_proforma_xml]

  include ExerciseExport

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
    @license_default = 1
    @license_hidden = false
    @form_action
  end


  def duplicate

    @exercise = Exercise.new
    @exercise_relation = ExerciseRelation.new

    exercise_origin = Exercise.find(params[:id])
    @exercise.private = exercise_origin.private
    @exercise_relation.origin = exercise_origin
    @exercise.errors[:base] = params[:errors].inspect if params[:errors]
    @license_default = @exercise_relation.origin.license_id
    @license_hidden = true

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
    @license_default = @exercise.license_id
    @license_hidden = false
    if @exercise.downloads > 0
      @license_hidden = true
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
    @exercise.soft_delete
    respond_to do |format|
      format.html { redirect_to exercises_url, notice: t('controllers.exercise.destroyed') }
      format.json { head :no_content }
    end
  end

  def add_to_cart
    cart = Cart.find_cart_of(current_user)
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
    @exercises = Exercise.all.paginate(per_page: 10, page: params[:page])
  end

  def related_exercises
    @related_exercises = Exercise.find(ExerciseRelation.where(origin_id: @exercise.id).collect(&:clone_id))
    respond_to do |format|
      format.html {render :index}
      format.js{ render 'load_related_exercises.js.erb' }
    end
  end

  def push_external
    account_link = AccountLink.find(params[:account_link])
    error = push_exercise(@exercise, account_link)
    if error.nil?
      redirect_to @exercise, notice: t('controllers.exercise.push_external_notice', account_link: account_link.readable)
    else
      puts error
      redirect_to @exercise, alert: t('controllers.account_links.not_working', account_link: account_link.readable)
    end
  end

  def download_exercise

    zip_file = create_exercise_zip(@exercise)
    if zip_file[:errors].any?
      zip_file[:errors].each do |error|
        logger.error(error)
      end
      redirect_to @exercise, alert: t('controllers.exercise.download_error')
    else
      downloads_new = @exercise.downloads+1
      @exercise.update(downloads: downloads_new)
      send_data(zip_file[:data], :type => 'application/zip', :filename => zip_file[:filename], :disposition => 'attachment' )
    end
  end

  def import_proforma_xml
    begin
      user = user_for_oauth2_request()
      exercise = Exercise.new
      request_body = request.body.read
      doc = Nokogiri::XML(request_body)
      importer = Proforma::Importer.new
      exercise = importer.from_proforma_xml(exercise, doc)
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
    files = Hash.new
    begin
      uploaded_io = params[:file_upload]
      raise t('controllers.exercise.choose_file') unless uploaded_io

      Zip::File.open(uploaded_io.path) do |zip_file|

        zip_file.each do |entry|
          name = entry.name.split('.').first
          extension = '.' + entry.name.split('.').second
          tempfile = Paperclip::Tempfile.new([name, extension])
          tempfile.write entry.get_input_stream.read
          tempfile.rewind
          files[entry.name.to_s] = tempfile
        end

        xml = zip_file.glob("task.xml").first
        raise t('controllers.exercise.taskxml_required') unless xml

        xml = xml.get_input_stream.read
        xsd = Nokogiri::XML::Schema(File.read('app/assets/taskxml.xsd'))
        doc = Nokogiri::XML(xml)

        errors = xsd.validate(doc)

        if errors.any?
          errors.each do |error|
            puts error.message
          end
          raise t('controllers.exercise.xml_not_valid')
        else
          exercise = Exercise.new
          importer = Proforma::ZipImporter.new
          exercise = importer.from_proforma_zip(exercise, doc, files)
          exercise.user = current_user
          saved = exercise.save

          if saved
            flash[:notice] = t('controllers.exercise.import_success')
            redirect_to edit_exercise_path(exercise.id)
          else
            raise t('controllers.exercise.import_fail')
          end
        end
      end
    rescue Exception => e
      flash[:alert] = e.message
      redirect_to exercises_path
    ensure
      files.each do |key, file|
        file.close
        file.unlink
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

  def restore_search_params
    search_params = session.delete(:exercise_search_params)&.symbolize_keys || {}
    params[:search] ||= search_params[:search]
    params[:settings] ||= search_params[:settings]
    params[:page] ||= search_params[:page]
  end

  def save_search_params
    session[:exercise_search_params] = {search: params[:search], settings: params[:settings], page: params[:page]}
  end

  def handle_search_params
    restore_search_params
    save_search_params
  end

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
    params.require(:exercise).permit(:title, :instruction, :maxrating, :private, :execution_environment_id)
  end
end
