# frozen_string_literal: true

require 'zip'

# rubocop:disable Metrics/ClassLength
class ExercisesController < ApplicationController
  load_and_authorize_resource except: %i[import_external_exercise import_uuid_check]
  before_action :set_exercise, only: %i[show edit update destroy add_to_cart add_to_collection push_external contribute
                                        remove_state export_external_start export_external_check]
  before_action :set_search, only: [:index]
  before_action :handle_search_params, only: :index
  skip_before_action :verify_authenticity_token, only: %i[import_external_exercise import_uuid_check]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.exercise.authorization')
  end

  # rubocop:disable Metrics/AbcSize will be fixed with ransack
  def index
    page = params[:page]
    @exercises = Exercise.active
                         .search(params[:search], params[:settings], @option, current_user)
                         .order(@order == 'order_created' ? {created_at: :desc} : {average_rating: :desc})
                         .paginate(per_page: 5, page: page)

    last_page = @exercises.total_pages
    @exercises = @exercises.page(last_page) if page.to_i > last_page
  end
  # rubocop:enable Metrics/AbcSize

  def show
    @user_rating = @exercise.ratings&.find_by(user: current_user)&.rating
    @exercise_relation = ExerciseRelation.find_by(clone_id: @exercise.id)

    @files = @exercise.exercise_files
    @tests = @exercise.tests
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
    @exercise.add_attributes(params[:exercise], current_user)
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
      if @exercise.update_and_version(exercise_params, params[:exercise], current_user)
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

  def export_external_start
    @account_link = AccountLink.find(params[:account_link])
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def export_external_check
    external_check = ExerciseService::CheckExternal.call(uuid: @exercise.uuid,
                                                         account_link: AccountLink.find(params[:account_link]))
    render json: {
      message: external_check[:message],
      actions: render_to_string(
        partial: 'export_actions',
        locals: {
          exercise: @exercise,
          exercise_found: external_check[:exercise_found],
          update_right: external_check[:update_right],
          error: external_check[:error],
          exported: false
        }
      )
    }, status: :ok
  end

  # rubocop:disable Metrics/AbcSize
  def export_external_confirm
    push_type = params[:push_type]

    return render json: {}, status: :internal_server_error unless %w[create_new export].include? push_type

    exercise, error = ProformaService::HandleExportConfirm.call(user: current_user, exercise: @exercise,
                                                                push_type: push_type, account_link_id: params[:account_link])
    exercise_title = exercise.title

    if error.nil?
      render json: {
        message: t('exercises.export_exercise.successfully_exported', title: exercise_title),
        status: 'success', actions: render_export_actions(exercise, true)
      }
    else
      render json: {
        message: t('exercises.export_exercise.export_failed', title: exercise_title, error: error),
        status: 'fail', actions: render_export_actions(exercise, false, error)
      }
    end
  end
  # rubocop:enable Metrics/AbcSize

  def download_exercise
    zip_file = ProformaService::ExportTask.call(exercise: @exercise)
    @exercise.update(downloads: @exercise.downloads + 1)
    send_data(zip_file.string, type: 'application/zip', filename: "task_#{@exercise.id}.zip", disposition: 'attachment')
  end

  def import_uuid_check
    user = user_for_api_request
    return render json: {}, status: :unauthorized if user.nil?

    exercise = Exercise.find_by(uuid: params[:uuid])
    return render json: {exercise_found: false} if exercise.nil?
    return render json: {exercise_found: true, update_right: false} unless exercise.updatable_by?(user)

    render json: {exercise_found: true, update_right: true}
  end

  def import_external_exercise
    user = user_for_api_request
    tempfile = tempfile_from_string(request.body.read.force_encoding('UTF-8'))

    ProformaService::Import.call(zip: tempfile, user: user)

    render json: t('controllers.exercise.import_proforma_xml.success'), status: :created
  rescue Proforma::ProformaError
    render json: t('controllers.exercise.import_proforma_xml.invalid'), status: :bad_request
  rescue StandardError
    render json: t('controllers.exercise.import_proforma_xml.internal_error'), status: :internal_server_error
  end

  def import_exercise_start
    zip_file = params[:zip_file]
    raise t('controllers.exercise.choose_file') unless zip_file.presence

    @data = ProformaService::CacheImportFile.call(user: current_user, zip_file: zip_file)

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def import_exercise_confirm
    task = ProformaService::TaskFromCachedFile.call(import_exercise_confirm_params.to_hash.symbolize_keys)

    exercise = ProformaService::ImportTask.call(task: task, user: current_user)
    task_title = task.title
    render json: {
      status: 'success',
      message: t('exercises.import_exercise.successfully_imported', title: task_title),
      actions: render_to_string(partial: 'import_actions', locals: {exercise: exercise, imported: true})
    }
  rescue Proforma::ProformaError, ActiveRecord::RecordInvalid => e
    render json: {
      status: 'failure',
      message: t('exercises.import_exercise.import_failed', title: task_title, error: e.message),
      actions: ''
    }
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

  def exercise_params
    params.require(:exercise).permit(:title, :instruction, :maxrating, :private, :execution_environment_id)
  end

  def import_exercise_confirm_params
    params.permit(:import_id, :subfile_id, :import_type)
  end

  def user_for_api_request
    authorization_header = request.headers['Authorization']
    api_key = authorization_header&.split(' ')&.second
    user_by_api_key(api_key)
  end

  def user_by_api_key(api_key)
    AccountLink.find_by_api_key(api_key)&.user
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

  def render_export_actions(exercise, exported, error = nil)
    render_to_string(partial: 'export_actions', locals: {exercise: exercise, exported: exported, error: error})
  end
end
# rubocop:enable Metrics/ClassLength
