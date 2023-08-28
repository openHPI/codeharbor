# frozen_string_literal: true

require 'zip'

class TasksController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :load_and_authorize_task, except: %i[index new create import_start import_confirm import_uuid_check import_external]
  before_action :load_and_authorize_account_link, only: %i[export_external_start export_external_check export_external_confirm]
  before_action :only_authorize_action, only: %i[import_start import_confirm import_uuid_check import_external]

  before_action :handle_search_params, only: :index
  before_action :set_search, only: [:index]
  prepend_before_action :set_user_for_api_request, only: %i[import_uuid_check import_external]
  skip_before_action :verify_authenticity_token, only: %i[import_uuid_check import_external]
  skip_before_action :require_user!, only: %i[show download]

  def index
    page = params[:page]
    @search = Task.visibility(@visibility, current_user).ransack(params[:q])
    @tasks = @search.result(distinct: true).paginate(page:, per_page: per_page_param).includes(:ratings, :programming_language,
      :labels, :user, :groups).load

    authorize @tasks
  end

  def duplicate
    new_entry = @task.clean_duplicate(current_user)
    if new_entry.save(context: :force_validations)
      redirect_to new_entry, notice: t('common.notices.object_duplicated', model: Task.model_name.human)
    else
      redirect_to @task, alert: t('.error_alert')
    end
  end

  def show
    @files = @task.files
    @tests = @task.tests
    @model_solutions = @task.model_solutions

    @user_rating = @task.ratings&.find_by(user: current_user) || Rating.new(Rating::CATEGORIES.index_with {|_category| 0 })
  end

  def new
    @task = Task.new
    authorize @task
  end

  def edit; end

  def create
    @task = Task.new(task_params)

    TaskService::HandleGroups.call(user: current_user, task: @task, group_tasks_params:)
    @task.user = current_user

    authorize @task

    if @task.save(context: :force_validations)
      redirect_to @task, notice: t('common.notices.object_created', model: Task.model_name.human)
    else
      render :new
    end
  end

  def update
    @task.assign_attributes(task_params)
    TaskService::HandleGroups.call(user: current_user, task: @task, group_tasks_params:)
    if @task.save(context: :force_validations)
      redirect_to @task, notice: t('common.notices.object_updated', model: Task.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @task.destroy!
    redirect_to tasks_url, notice: t('common.notices.object_deleted', model: Task.model_name.human)
  end

  def add_to_collection
    collection = Collection.find(params[:collection])
    if collection.add_task(@task)
      redirect_to @task, notice: t('.success_notice')
    else
      redirect_to @task, alert: t('.error')
    end
  end

  def download
    zip_file = ProformaService::ExportTask.call(task: @task, options: {version: params[:version]})
    send_data(zip_file.string, type: 'application/zip', filename: "task_#{@task.id}.zip", disposition: 'attachment')
  rescue ProformaXML::PostGenerateValidationError => e
    redirect_to :root, danger: JSON.parse(e.message).map {|msg| t("proforma_errors.#{msg}", default: msg) }.join('<br>')
  end

  def import_start # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    zip_file = params[:zip_file]
    unless zip_file.is_a?(ActionDispatch::Http::UploadedFile)
      return render json: {status: 'failure', message: t('.choose_file_error')}
    end

    @data = ProformaService::CacheImportFile.call(user: current_user, zip_file:)

    respond_to do |format|
      format.js { render layout: false }
    end
  rescue ProformaXML::ProformaError => e
    messages = prettify_import_errors(e)
    flash[:alert] = messages
    render json: {
      status: 'failure',
      message: t('.error', error: messages),
      actions: '',
    }
  rescue StandardError => e
    Sentry.capture_exception(e)
    render json: {
      status: 'failure',
      message: t('tasks.import.internal_error'),
      actions: '',
    }
  end

  def import_confirm # rubocop:disable Metrics/AbcSize
    proforma_task = ProformaService::ProformaTaskFromCachedFile.call(**import_confirm_params.to_hash.symbolize_keys)

    task = ProformaService::ImportTask.call(proforma_task:, user: current_user)
    render json: {
      status: 'success',
      message: t('.success', title: proforma_task.title),
      actions: render_to_string(partial: 'import_actions', locals: {task:, imported: true}),
    }
  rescue ProformaXML::ProformaError, ActiveRecord::RecordInvalid => e
    render json: {
      status: 'failure',
      message: t('.error', title: proforma_task.title, error: e.message),
      actions: '',
    }
  rescue StandardError => e
    Sentry.capture_exception(e)
    render json: {
      status: 'failure',
      message: t('tasks.import.internal_error'),
      actions: '',
    }
  end

  def import_uuid_check
    task = Task.find_by(uuid: params[:uuid])
    return render json: {uuid_found: false} if task.nil?
    return render json: {uuid_found: true, update_right: false} unless Pundit.policy(current_user, task).manage?

    render json: {uuid_found: true, update_right: true}
  end

  def import_external
    tempfile = tempfile_from_string(request.body.read.force_encoding('UTF-8'))

    ProformaService::Import.call(zip: tempfile, user: current_user)

    render json: t('.success'), status: :created
  rescue ProformaXML::ProformaError
    render json: t('.invalid'), status: :bad_request
  rescue StandardError => e
    Sentry.capture_exception(e)
    render json: t('tasks.import.internal_error'), status: :internal_server_error
  end

  def export_external_start
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def export_external_check
    external_check = TaskService::CheckExternal.call(uuid: @task.uuid, account_link: @account_link)
    render json: {
      message: external_check[:message],
      actions: render_export_actions(task: @task,
        task_found: external_check[:uuid_found],
        update_right: external_check[:update_right],
        error: external_check[:error],
        exported: false),
    }, status: :ok
  end

  def export_external_confirm
    push_type = params[:push_type]

    return render json: {}, status: :internal_server_error unless %w[create_new export].include? push_type

    export_task, error = ProformaService::HandleExportConfirm.call(user: current_user, task: @task, push_type:, account_link: @account_link)
    task_title = export_task.title

    if error.nil?
      render json: {
        message: t('.success', title: task_title),
        status: 'success', actions: render_export_actions(task: export_task, exported: true)
      }
    else
      export_task.destroy if push_type == 'create_new'
      render json: {
        message: t('.error', title: task_title, error:),
        status: 'fail', actions: render_export_actions(task: @task, exported: false, error:)
      }
    end
  end

  def generate_test
    GptService::GenerateTests.call(task: @task, openai_api_key: current_user.openai_api_key)
    flash[:notice] = I18n.t('tasks.task_service.gpt_generate_tests.successful_generation')
  rescue Gpt::Error => e
    flash[:alert] = e.localized_message
  ensure
    redirect_to @task
  end

  private

  def prettify_import_errors(error)
    message = "#{t('proforma_errors.import')}<br>"
    message + JSON.parse(error.message).map do |msg|
                t("proforma_errors.#{msg}", default: msg)
              end.join('<br>')
  end

  def load_and_authorize_task
    @task = Task.find(params[:id])
    authorize @task
  end

  def load_and_authorize_account_link
    @account_link = AccountLink.find(params[:account_link])
    authorize @account_link, :use?
  end

  def only_authorize_action
    authorize Task
  end

  def set_search # rubocop:disable Metrics/AbcSize
    search = params[:q]
    @req_labels = []

    if search.is_a?(ActionController::Parameters)
      @created_before_days = search[:created_before_days]
      @min_stars = search[:min_stars]
      @access_level = search[:access_level]
      @req_labels = Label.where(name: search['has_all_labels'].compact_blank) if search['has_all_labels']
    end

    @visibility = params[:visibility]&.to_sym || :owner
    @advanced_filter_active = params[:advancedFilterActive]
  end

  def restore_search_params
    search_params = session.delete(:task_search_params)&.symbolize_keys || {}
    %i[q advancedFilterActive page min_stars].each do |key|
      params[key] ||= search_params[key]
    end
  end

  def save_search_params
    session[:task_search_params] = {q: params[:q], advancedFilterActive: params[:advancedFilterActive], page: params[:page]}
  end

  def handle_search_params
    restore_search_params
    save_search_params
  end

  def file_params
    %i[id content attachment path name internal_description mime_type use_attached_file used_by_grader visible usage_by_lms xml_id _destroy
       parent_id]
  end

  def test_params
    [:id, :title, :testing_framework_id, :description, :internal_description, :test_type, :xml_id, :validity, :timeout, :_destroy,
     :parent_id, {files_attributes: file_params}]
  end

  def model_solution_params
    [:id, :description, :internal_description, :xml_id, :_destroy, :parent_id, {files_attributes: file_params}]
  end

  def task_params
    params.require(:task).permit(:title, :description, :internal_description, :parent_uuid, :language, :license_id,
      :programming_language_id, :access_level, files_attributes: file_params, tests_attributes: test_params,
      model_solutions_attributes: model_solution_params, label_names: [])
  end

  def group_tasks_params
    params.require(:group_tasks).permit(group_ids: [])
  end

  def import_confirm_params
    params.permit(:import_id, :subfile_id, :import_type)
  end

  def set_user_for_api_request
    authorization_header = request.headers['Authorization']
    api_key = authorization_header&.split&.second
    @current_user = user_by_api_key(api_key)
  end

  def user_by_api_key(api_key)
    AccountLink.find_by(api_key:)&.user
  end

  def tempfile_from_string(string)
    Tempfile.new('codeharbor_import.zip').tap do |tempfile|
      tempfile.write string
      tempfile.rewind
    end
  end

  def render_export_actions(task:, exported:, error: nil, task_found: nil, update_right: nil)
    render_to_string(partial: 'export_actions',
      formats: :html,
      locals: {task:, exported:, error:, task_found:, update_right:})
  end
end
