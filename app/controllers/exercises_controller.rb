# frozen_string_literal: true

require 'oauth2'
require 'zip'

# rubocop:disable Metrics/ClassLength
class ExercisesController < ApplicationController
  load_and_authorize_resource except: [:import_proforma_xml]
  before_action :set_exercise, only: %i[show edit update destroy add_to_cart add_to_collection push_external contribute]
  before_action :set_search, only: [:index]
  before_action :handle_search_params, only: :index
  skip_before_action :verify_authenticity_token, only: [:import_proforma_xml]

  include ExerciseExport

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.exercise.authorization')
  end

  def index
    order_param = {average_rating: :desc}
    order_param = {created_at: :desc} if @order == 'order_created'

    @exercises = Exercise.search(params[:search], params[:settings], @option, current_user).order(order_param)
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
    @exercise.add_attributes(params[:exercise])
    respond_to do |format|
      if @exercise.update(exercise_params)
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

  def push_external
    account_link = AccountLink.find(params[:account_link])
    error = push_exercise(@exercise, account_link)
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

  # rubocop:disable Metrics/AbcSize
  def import_proforma_xml
    user = user_for_oauth2_request
    exercise = Exercise.new
    request_body = request.body.read
    doc = Nokogiri::XML(request_body)
    importer = Proforma::Importer.new
    exercise = importer.from_proforma_xml(exercise, doc)
    exercise.user = user
    saved = exercise.save
    if saved
      render text: t('controllers.exercise.import_proforma_xml.success'), status: 200
    else
      logger.info(exercise.errors.full_messages)
      render text: t('controllers.exercise.import_proforma_xml.invalid'), status: 400
    end
  rescue StandardError => e
    raise e unless e.class == Hash

    render text: e.message, status: e.status
  end
  # rubocop:enable Metrics/AbcSize

  def import_exercise
    uploaded_io = params[:file_upload]
    raise t('controllers.exercise.choose_file') unless uploaded_io

    begin
      result = ProformaService::Import.call(zip: uploaded_io, user: current_user)

      if result.is_a?(Array)
        return redirect_to exercises_path, notice: t('controllers.exercise.import_proforma_xml.multi_import_successful', count: result.length)
      end

      redirect_to edit_exercise_path(result), notice: t('controllers.exercise.import_proforma_xml.single_import_successful')
    rescue Proforma::PreImportValidationError => e
      redirect_to exercises_path, alert: t('controllers.exercise.import_proforma_xml.validation_error')
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
    raise(status: 401, message: t('controllers.exercise.import_proforma_xml.no_header')) if authorization_header.nil?

    oauth2_token = oauth_token_from_header(authorization_header)
    raise(status: 401, message: t('controllers.exercise.import_proforma_xml.no_token')) if oauth2_token.blank?

    user = user_by_code_harbor_token(oauth2_token)
    raise(status: 401, message: t('controllers.exercise.import_proforma_xml.unknown_token')) if user.nil?

    user
  end

  def oauth_token_from_header(header)
    header.split(' ')[1]
  end

  def user_by_code_harbor_token(oauth2_token)
    link = AccountLink.where(oauth2_token: oauth2_token)[0]
    return link.user unless link.nil?
  end
end
# rubocop:enable Metrics/ClassLength
