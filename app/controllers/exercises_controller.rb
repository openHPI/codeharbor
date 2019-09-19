# frozen_string_literal: true

require 'zip'

# rubocop:disable Metrics/ClassLength
class ExercisesController < ApplicationController
  load_and_authorize_resource except: [:import_exercise_oauth]
  before_action :set_exercise, only: %i[show edit update destroy add_to_cart add_to_collection push_external contribute remove_state]
  before_action :set_search, only: [:index]
  before_action :handle_search_params, only: :index
  skip_before_action :verify_authenticity_token, only: [:import_exercise_oauth]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.exercise.authorization')
  end

  def index
    order_param = {average_rating: :desc}
    order_param = {created_at: :desc} if @order == 'order_created'

    @exercises = Exercise.active
                         .search(params[:search], params[:settings], @option, current_user).order(order_param)
                         .paginate(per_page: 5, page: params[:page])
  end

  def show
    exercise_relation = ExerciseRelation.find_by(clone_id: @exercise.id)
    @exercise_relation = exercise_relation if exercise_relation
    if @exercise.ratings
      user_rating = @exercise.ratings.find_by(user: current_user)
      @user_rating = user_rating.rating if user_rating
    end

    @files = ExerciseFile.where(exercise: @exercise)
    @tests = Test.where(exercise: @exercise)
  end

  def new
    @exercise = Exercise.new
    @exercise.descriptions << Description.new
    @license_default = 1
    @license_hidden = false
    @form_action
  end

  def duplicate
    exercise_origin = Exercise.find(params[:id])

    @exercise = exercise_origin.duplicate
    @exercise_relation = ExerciseRelation.new

    @exercise_relation.origin = exercise_origin
    @exercise.errors[:base] = params[:errors].inspect if params[:errors]
    @license_default = @exercise_relation.origin.license_id
    @license_hidden = true

    @form_action
  end

  def edit
    exercise_relation = ExerciseRelation.find_by(clone_id: params[:id])
    @exercise_relation = exercise_relation if exercise_relation
    @license_default = @exercise.license_id
    @license_hidden = false
    @license_hidden = true if @exercise.downloads.positive?
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @exercise = Exercise.new(exercise_params)
    @exercise.add_attributes(params[:exercise])
    @exercise.user = current_user

    respond_to do |format|
      if @exercise.save
        format.html { redirect_to @exercise, notice: t('controllers.exercise.created') }
        format.json { render :show, status: :created, location: @exercise }
      else
        if !params[:exercise][:exercise_relation] # Exercise Relation is set if form is for duplicate exercise, otherwise it's not.
          format.html { render :new }
        else
          format.html { redirect_to duplicate_exercise_path(params[:exercise][:exercise_relation][:origin_id]) }
        end
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @exercise.state_list = []
    respond_to do |format|
      if @exercise.update_and_version(exercise_params, params[:exercise])
        format.html { redirect_to @exercise, notice: t('controllers.exercise.updated') }
        format.json { render :show, status: :ok, location: @exercise }
      else
        format.html { render :edit }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    @exercise.soft_delete
    respond_to do |format|
      format.html { redirect_to exercises_url, notice: t('controllers.exercise.destroyed') }
      format.json { head :no_content }
    end
  end

  def remove_state
    flash[:notice] = t('exercises.state_removed') if @exercise.update(state_list: [])
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
      format.html { render :index }
      format.js { render 'load_related_exercises.js.erb' }
    end
  end

  def history
    @history_exercises = @exercise.complete_history
    @history_exercises.map!.with_index do |exercise, index|
      version = if exercise == @exercise
                  'selected'
                else
                  index.zero? ? 'latest' : @history_exercises.length - index
                end
      {
        exercise: exercise,
        version: version
      }
    end
    respond_to do |format|
      format.js { render 'load_history.js.erb' }
    end
  end

  def push_external
    account_link = AccountLink.find(params[:account_link])
    error = ExerciseService::PushExternal.call(zip: ProformaService::ExportTask.call(exercise: @exercise), account_link: account_link)
    if error.nil?
      redirect_to @exercise, notice: t('controllers.exercise.push_external_notice', account_link: account_link.readable)
    else
      logger.debug(error)
      redirect_to @exercise, alert: t('controllers.account_links.not_working', account_link: account_link.readable)
    end
  end

  def download_exercise
    zip_file = ProformaService::ExportTask.call(exercise: @exercise)
    @exercise.update(downloads: @exercise.downloads + 1)
    send_data(zip_file.string, type: 'application/zip', filename: "task_#{@exercise.id}.zip", disposition: 'attachment')
  end

  def import_exercise_oauth
    user = user_for_oauth2_request
    tempfile = tempfile_from_string(request.body.read.force_encoding('UTF-8'))

    ProformaService::Import.call(zip: tempfile, user: user)

    render json: t('controllers.exercise.import_proforma_xml.success'), status: 201
  rescue Proforma::PreImportValidationError, Proforma::InvalidZip
    render json: t('controllers.exercise.import_proforma_xml.invalid'), status: 400
  end

  def import_exercise
    uploaded_io = params[:file_upload]
    raise t('controllers.exercise.choose_file') unless uploaded_io

    handle_proforma_import(zip: uploaded_io, user: current_user)
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
    send_added_author_message(user, @exercise)

    Message.where(sender: user, recipient: current_user, param_type: 'exercise', param_id: @exercise.id).delete_all
    redirect_to user_messages_path(current_user), notice: t('controllers.exercise.add_author_notice')
  end

  def decline_author
    user = User.find(params[:user])
    send_declined_author_message(user, @exercise)

    Message.where(sender: user, recipient: current_user, param_type: 'exercise', param_id: @exercise.id).delete_all
    redirect_to user_messages_path(current_user), notice: t('controllers.exercise.decline_author_notice')
  end

  # rubocop:disable Metrics/AbcSize
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
        # Insert message for "Revision Board" here
      end
      redirect_to exercise_path(@exercise), notice: t('controllers.exercise.report_notice')
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def send_declined_author_message(user, exercise)
    text = t('controllers.exercise.decline_author_text', user: current_user.name, exercise: exercise.title)
    Message.create(sender: current_user,
                   recipient: user,
                   param_type: 'exercise_declined',
                   text: text,
                   sender_status: 'd')
  end

  def send_added_author_message(user, exercise)
    text = t('controllers.exercise.add_author_text', user: current_user.name, exercise: exercise.title)
    Message.create(sender: current_user,
                   recipient: user,
                   param_type: 'exercise_accepted',
                   param_id: exercise.id,
                   text: text,
                   sender_status: 'd')
  end

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

  # will be replaced with ransack
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/AbcSize
  def set_search
    @option = params[:option] || 'mine'

    @order = params[:order_param] || 'order_rating'

    @dropdown = params[:window] || false

    @stars = if params[:settings]
               params[:settings][:stars]
             else
               '0'
             end

    @languages = params[:settings][:language] if params[:settings]

    @proglanguages = params[:settings][:proglanguage] if params[:settings]

    @created = if params[:settings]
                 params[:settings][:created]
               else
                 '0'
               end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  # Use callbacks to share common setup or constraints between actions.
  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def exercise_params
    params.require(:exercise).permit(:title, :instruction, :maxrating, :private, :execution_environment_id)
  end

  def user_for_oauth2_request
    authorization_header = request.headers['Authorization']
    api_key = authorization_header&.split(' ')&.second
    user_by_code_harbor_token(api_key)
  end

  def user_by_code_harbor_token(api_key)
    link = AccountLink.where(api_key: api_key)[0]
    link&.user
  end

  def handle_proforma_import(zip:, user:)
    result = ProformaService::Import.call(zip: zip, user: user)

    return handle_proforma_multi_import(result) if result.is_a?(Array)

    redirect_to result, notice: t('controllers.exercise.import_proforma_xml.single_import_successful')
  rescue Proforma::PreImportValidationError, Proforma::InvalidZip
    redirect_to exercises_path, alert: t('controllers.exercise.import_proforma_xml.import_error')
  end

  def handle_proforma_multi_import(result)
    if result.empty?
      redirect_to exercises_path, alert: t('controllers.exercise.import_proforma_xml.no_file_present')
    else
      redirect_to exercises_path,
                  notice: t('controllers.exercise.import_proforma_xml.multi_import_successful', count: result.length)
    end
  end

  def tempfile_from_string(string)
    Tempfile.new('codeharbor_import.zip').tap do |tempfile|
      tempfile.write string
      tempfile.rewind
    end
  end
end
# rubocop:enable Metrics/ClassLength
