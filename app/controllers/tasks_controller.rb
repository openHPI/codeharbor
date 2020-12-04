# frozen_string_literal: true

require 'zip'

# rubocop:disable Metrics/ClassLength
class TasksController < ApplicationController
  load_and_authorize_resource except: %i[import_external_exercise import_uuid_check]
  before_action :set_task, only: %i[show edit update destroy add_to_cart add_to_collection contribute
                                        remove_state export_external_start export_external_check]
  before_action :validate_account_link_usage, only: %i[export_external_start export_external_check export_external_confirm]
  before_action :set_search, only: [:index]
  before_action :handle_search_params, only: :index
  skip_before_action :verify_authenticity_token, only: %i[import_external_exercise import_uuid_check]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.exercise.authorization')
  end

  def index
    page = params[:page]
    @tasks = Task#.active
                         .search(params[:search], params[:settings], @option, current_user)
                         .paginate(per_page: 5, page: page)
                         # .order(@order == 'order_created' ? {created_at: :desc} : {average_rating: :desc})

    last_page = @tasks.total_pages
    @tasks = @tasks.page(last_page) if page.to_i > last_page
  end

  def show
    # @user_rating = @task.ratings&.find_by(user: current_user)&.rating
    # @task_relation = ExerciseRelation.find_by(clone_id: @task.id)

    @files = @task.files
    @tests = @task.tests
    @model_solutions = @task.model_solutions
  end

  def new
    @task = Task.new
    # @task.descriptions << Description.new
    # @license_default = 1
    # @license_hidden = false
  end

  # def duplicate
  #   exercise_origin = Exercise.find(params[:id])
  #
  #   @task = exercise_origin.duplicate
  #   @task_relation = ExerciseRelation.new
  #
  #   @task_relation.origin = exercise_origin
  #   @task.errors[:base] = params[:errors].inspect if params[:errors]
  #   @license_default = @task_relation.origin.license_id
  #   @license_hidden = true
  #
  #   @form_action
  # end

  def edit
    # exercise_relation = ExerciseRelation.find_by(clone_id: params[:id])
    # @task_relation = exercise_relation if exercise_relation
    # @license_default = @task.license_id
    # @license_hidden = false
    # @license_hidden = true if @task.downloads.positive?
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @task = Task.new(task_params)
    # @task.add_attributes(params[:exercise], current_user)
    @task.user = current_user

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: t('tasks.notification.created') }
        format.json { render :show, status: :created, location: @task }
      else
        # if params[:exercise][:exercise_relation] # Exercise Relation is set if form is for duplicate exercise, otherwise it's not.
        #   format.html { redirect_to duplicate_exercise_path(params[:exercise][:exercise_relation][:origin_id]) }
        # else
          format.html { render :new }
        # end
        # format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # @task.state_list = []
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: t('tasks.notification.updated') }
      else
        format.html { render :edit }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    @task.destroy!
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: t('tasks.notification.destroyed') }
      format.json { head :no_content }
    end
  end

  # def remove_state
  #   flash[:notice] = t('exercises.state_removed') if @task.update(state_list: [])
  # end

  # def add_to_cart
  #   cart = Cart.find_cart_of(current_user)
  #   if cart.add_exercise(@task)
  #     redirect_to @task, notice: t('controllers.exercise.add_to_cart_success')
  #   else
  #     redirect_to @task, alert: t('controllers.exercise.add_to_cart_fail')
  #   end
  # end

  # def add_to_collection
  #   collection = Collection.find(params[:collection])
  #   if collection.add_exercise(@task)
  #     redirect_to @task, notice: t('controllers.exercise.add_to_collection_success')
  #   else
  #     redirect_to @task, alert: t('controllers.exercise.add_to_collection_fail')
  #   end
  # end

  # def related_exercises
  #   @related_exercises = Exercise.find(ExerciseRelation.where(origin_id: @task.id).collect(&:clone_id))
  #   respond_to do |format|
  #     format.html { render :index }
  #     format.js { render 'load_related_exercises.js.erb' }
  #   end
  # end

  # def history
  #   @history_exercises = @task.complete_history
  #   @history_exercises.map!.with_index do |exercise, index|
  #     version = if exercise == @task
  #                 'selected'
  #               else
  #                 index.zero? ? 'latest' : @history_exercises.length - index
  #               end
  #     {
  #       exercise: exercise,
  #       version: version
  #     }
  #   end
  #   respond_to do |format|
  #     format.js { render 'load_history.js.erb' }
  #   end
  # end

  # def export_external_start
  #   @account_link = AccountLink.find(params[:account_link])
  #
  #   respond_to do |format|
  #     format.js { render layout: false }
  #   end
  # end

  # def export_external_check
  #   external_check = ExerciseService::CheckExternal.call(uuid: @task.uuid,
  #                                                        account_link: AccountLink.find(params[:account_link]))
  #   render json: {
  #     message: external_check[:message],
  #     actions: render_to_string(
  #       partial: 'export_actions.html.slim',
  #       locals: {
  #         exercise: @task,
  #         exercise_found: external_check[:exercise_found],
  #         update_right: external_check[:update_right],
  #         error: external_check[:error],
  #         exported: false
  #       }
  #     )
  #   }, status: :ok
  # end

  # def export_external_confirm
  #   push_type = params[:push_type]
  #
  #   return render json: {}, status: :internal_server_error unless %w[create_new export].include? push_type
  #
  #   exercise, error = ProformaService::HandleExportConfirm.call(user: current_user, exercise: @task,
  #                                                               push_type: push_type, account_link_id: params[:account_link])
  #   exercise_title = exercise.title
  #
  #   if error.nil?
  #     render json: {
  #       message: t('exercises.export_exercise.successfully_exported', title: exercise_title),
  #       status: 'success', actions: render_export_actions(exercise, true)
  #     }
  #   else
  #     render json: {
  #       message: t('exercises.export_exercise.export_failed', title: exercise_title, error: error),
  #       status: 'fail', actions: render_export_actions(exercise, false, error)
  #     }
  #   end
  # end

  # def download_exercise
  #   zip_file = ProformaService::ExportTask.call(exercise: @task)
  #   @task.update(downloads: @task.downloads + 1)
  #   send_data(zip_file.string, type: 'application/zip', filename: "task_#{@task.id}.zip", disposition: 'attachment')
  # end

  # def import_uuid_check
  #   user = user_for_api_request
  #   return render json: {}, status: :unauthorized if user.nil?
  #
  #   exercise = Exercise.find_by(uuid: params[:uuid])
  #   return render json: {exercise_found: false} if exercise.nil?
  #   return render json: {exercise_found: true, update_right: false} unless exercise.updatable_by?(user)
  #
  #   render json: {exercise_found: true, update_right: true}
  # end

  # def import_external_exercise
  #   user = user_for_api_request
  #   tempfile = tempfile_from_string(request.body.read.force_encoding('UTF-8'))
  #
  #   ProformaService::Import.call(zip: tempfile, user: user)
  #
  #   render json: t('controllers.exercise.import_proforma_xml.success'), status: :created
  # rescue Proforma::ProformaError
  #   render json: t('controllers.exercise.import_proforma_xml.invalid'), status: :bad_request
  # rescue StandardError => e
  #   Raven.capture_exception(e)
  #   render json: t('controllers.exercise.import_proforma_xml.internal_error'), status: :internal_server_error
  # end

  # def import_exercise_start
  #   zip_file = params[:zip_file]
  #   raise t('controllers.exercise.choose_file') unless zip_file.presence
  #
  #   @data = ProformaService::CacheImportFile.call(user: current_user, zip_file: zip_file)
  #
  #   respond_to do |format|
  #     format.js { render layout: false }
  #   end
  # end

  # def import_exercise_confirm
  #   task = ProformaService::TaskFromCachedFile.call(import_exercise_confirm_params.to_hash.symbolize_keys)
  #
  #   exercise = ProformaService::ImportTask.call(task: task, user: current_user)
  #   task_title = task.title
  #   render json: {
  #     status: 'success',
  #     message: t('exercises.import_exercise.successfully_imported', title: task_title),
  #     actions: render_to_string(partial: 'import_actions', locals: {exercise: exercise, imported: true})
  #   }
  # rescue Proforma::ProformaError, ActiveRecord::RecordInvalid => e
  #   render json: {
  #     status: 'failure',
  #     message: t('exercises.import_exercise.import_failed', title: task_title, error: e.message),
  #     actions: ''
  #   }
  # end

  # def contribute
  #   author = @task.user
  #   AccessRequestMailer.send_contribution_request(author, @task, current_user).deliver_later
  #   text = t('controllers.exercise.contribute', user: current_user.name, exercise: @task.title)
  #   Message.create(sender: current_user, recipient: author, param_type: 'exercise', param_id: @task.id, text: text, sender_status: 'd')
  #   redirect_to exercises_path, notice: t('controllers.exercise.contribute_notice')
  # end

  # def add_author
  #   user = User.find(params[:user])
  #   ExerciseAuthor.create(user: user, exercise: @task)
  #   send_added_author_message(user, @task)
  #
  #   Message.where(sender: user, recipient: current_user, param_type: 'exercise', param_id: @task.id).delete_all
  #   redirect_to user_messages_path(current_user), notice: t('controllers.exercise.add_author_notice')
  # end

  # def decline_author
  #   user = User.find(params[:user])
  #   send_declined_author_message(user, @task)
  #
  #   Message.where(sender: user, recipient: current_user, param_type: 'exercise', param_id: @task.id).delete_all
  #   redirect_to user_messages_path(current_user), notice: t('controllers.exercise.decline_author_notice')
  # end

  # rubocop:disable Metrics/AbcSize
  # def report
  #   report = Report.find_by(user: current_user, exercise: @task)
  #   if report
  #     redirect_to exercise_path(@task), alert: t('controllers.exercise.report_alert')
  #   else
  #     Report.create(user: current_user, exercise: @task, text: params[:text])
  #     if @task.reports == 1
  #       Message.create(recipient: @task.user, param_type: 'report', param_id: @task.id, text: text, sender_status: 'd')
  #       @task.exercise_authors.each do |author|
  #         Message.create(recipient: author, param_type: 'report', param_id: @task.id, text: text, sender_status: 'd')
  #       end
  #       # Insert message for "Revision Board" here
  #     end
  #     redirect_to exercise_path(@task), notice: t('controllers.exercise.report_notice')
  #   end
  # end
  # rubocop:enable Metrics/AbcSize

  private

  # def send_declined_author_message(user, exercise)
  #   text = t('controllers.exercise.decline_author_text', user: current_user.name, exercise: exercise.title)
  #   Message.create(sender: current_user,
  #                  recipient: user,
  #                  param_type: 'exercise_declined',
  #                  text: text,
  #                  sender_status: 'd')
  # end

  # def send_added_author_message(user, exercise)
  #   text = t('controllers.exercise.add_author_text', user: current_user.name, exercise: exercise.title)
  #   Message.create(sender: current_user,
  #                  recipient: user,
  #                  param_type: 'exercise_accepted',
  #                  param_id: exercise.id,
  #                  text: text,
  #                  sender_status: 'd')
  # end

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
  def set_task
    @task = Task.find(params[:id])
  end

  def file_params
    %i[id content attachment path name internal_description mime_type used_by_grader visible usage_by_lms _destroy]
  end

  def test_params
    [:id, :title, :description, :internal_description, :test_type, :xml_id, :validity, :timeout, :_destroy, {files_attributes: file_params}]
  end

  def model_solution_params
    [:id, :description, :internal_description, :xml_id, :_destroy, {files_attributes: file_params}]
  end

  def task_params
    params.require(:task).permit(:title, :description, :internal_description, :parent_uuid, :language,
                                 :programming_language_id, files_attributes: file_params, tests_attributes: test_params,
                                 model_solutions_attributes: model_solution_params)
  end

  # def import_exercise_confirm_params
  #   params.permit(:import_id, :subfile_id, :import_type)
  # end

  # def user_for_api_request
  #   authorization_header = request.headers['Authorization']
  #   api_key = authorization_header&.split(' ')&.second
  #   user_by_api_key(api_key)
  # end

  # def user_by_api_key(api_key)
  #   AccountLink.find_by(api_key: api_key)&.user
  # end

  # def handle_proforma_multi_import(result)
  #   if result.empty?
  #     redirect_to exercises_path, alert: t('controllers.exercise.import_proforma_xml.no_file_present')
  #   else
  #     redirect_to exercises_path,
  #                 notice: t('controllers.exercise.import_proforma_xml.multi_import_successful', count: result.length)
  #   end
  # end

  # def tempfile_from_string(string)
  #   Tempfile.new('codeharbor_import.zip').tap do |tempfile|
  #     tempfile.write string
  #     tempfile.rewind
  #   end
  # end

  # def render_export_actions(exercise, exported, error = nil)
  #   render_to_string(partial: 'export_actions.html.slim', locals: {exercise: exercise, exported: exported, error: error})
  # end

  # def validate_account_link_usage
  #   return if AccountLink.find(params[:account_link]).usable_by?(current_user)
  #
  #   respond_to do |format|
  #     format.js { redirect_to @task, alert: t('controllers.exercise.account_link_authorization') }
  #     format.json { render json: {error: t('controllers.exercise.account_link_authorization')} }
  #   end
  # end
end
# rubocop:enable Metrics/ClassLength
