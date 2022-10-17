# frozen_string_literal: true

require 'zip'

class TasksController < ApplicationController
  load_and_authorize_resource except: %i[import_external import_uuid_check]

  before_action :handle_search_params, only: :index
  before_action :set_search, only: [:index]
  skip_before_action :verify_authenticity_token, only: %i[import_external import_uuid_check]

  rescue_from CanCan::AccessDenied, ActiveRecord::RecordNotFound do |_exception|
    redirect_to root_path, alert: t('controllers.authorization')
  end

  def index
    page = params[:page]
    @search = Task.visibility(@visibility, current_user).ransack(params[:search])
    @tasks = @search.result(distinct: true).paginate(per_page: 5, page: page)
  end

  def show
    @files = @task.files
    @tests = @task.tests
    @model_solutions = @task.model_solutions

    @user_rating = @task.ratings&.find_by(user: current_user)&.rating
  end

  def new
    @task = Task.new
  end

  def edit; end

  def create
    @task = Task.new(task_params)

    @task.user = current_user

    if @task.save
      redirect_to @task, notice: t('tasks.notification.created')
    else
      render :new
    end
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: t('tasks.notification.updated')
    else
      render :edit
    end
  end

  def destroy
    @task.destroy!
    redirect_to tasks_url, notice: t('tasks.notification.destroyed')
  end

  def download
    zip_file = ProformaService::ExportTask.call(task: @task)
    send_data(zip_file.string, type: 'application/zip', filename: "task_#{@task.id}.zip", disposition: 'attachment')
  end

  def import_start
    zip_file = params[:zip_file]
    unless zip_file.is_a?(ActionDispatch::Http::UploadedFile)
      return render json: {status: 'failure', message: t('controllers.task.import.choose_file_error')}
    end

    @data = ProformaService::CacheImportFile.call(user: current_user, zip_file: zip_file)

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def import_confirm
    proforma_task = ProformaService::ProformaTaskFromCachedFile.call(**import_confirm_params.to_hash.symbolize_keys)

    proforma_task = ProformaService::ImportTask.call(proforma_task: proforma_task, user: current_user)
    task_title = proforma_task.title
    render json: {
      status: 'success',
      message: t('controllers.task.import.successfully_imported', title: task_title),
      actions: render_to_string(partial: 'import_actions', locals: {task: proforma_task, imported: true})
    }
  rescue Proforma::ProformaError, ActiveRecord::RecordInvalid => e
    render json: {
      status: 'failure',
      message: t('controllers.task.import.import_failed', title: task_title, error: e.message),
      actions: ''
    }
  end

  def import_uuid_check
    user = user_for_api_request
    return render json: {}, status: :unauthorized if user.nil?

    task = Task.find_by(uuid: params[:uuid])
    return render json: {uuid_found: false} if task.nil?
    return render json: {uuid_found: true, update_right: false} unless task.can_access(user)

    render json: {uuid_found: true, update_right: true}
  end

  def import_external
    user = user_for_api_request
    tempfile = tempfile_from_string(request.body.read.force_encoding('UTF-8'))

    ProformaService::Import.call(zip: tempfile, user: user)

    render json: t('controllers.exercise.import_proforma_xml.success'), status: :created
  rescue Proforma::ProformaError
    render json: t('controllers.exercise.import_proforma_xml.invalid'), status: :bad_request
  rescue StandardError => e
    Sentry.capture_exception(e)
    render json: t('controllers.exercise.import_proforma_xml.internal_error'), status: :internal_server_error
  end

  def export_external_start
    @account_link = AccountLink.find(params[:account_link])

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def export_external_check
    external_check = TaskService::CheckExternal.call(uuid: @task.uuid,
                                                     account_link: AccountLink.find(params[:account_link]))
    render json: {
      message: external_check[:message],
      actions: render_export_actions(task: @task,
                                     task_found: external_check[:uuid_found],
                                     update_right: external_check[:update_right],
                                     error: external_check[:error],
                                     exported: false)
    }, status: :ok
  end

  # rubocop:disable Metrics/AbcSize
  def export_external_confirm
    push_type = params[:push_type]

    return render json: {}, status: :internal_server_error unless %w[create_new export].include? push_type

    export_task, error = ProformaService::HandleExportConfirm.call(user: current_user, task: @task,
                                                                   push_type: push_type, account_link_id: params[:account_link])
    task_title = export_task.title

    if error.nil?
      render json: {
        message: t('tasks.export_task.successfully_exported', title: task_title),
        status: 'success', actions: render_export_actions(task: export_task, exported: true)
      }
    else
      export_task.destroy if push_type == 'create_new'
      render json: {
        message: t('tasks.export_task.export_failed', title: task_title, error: error),
        status: 'fail', actions: render_export_actions(task: @task, exported: false, error: error)
      }
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def set_search
    search = params[:search]
    if search.is_a?(ActionController::Parameters)
      @created_before_days = search[:created_before_days]
      @min_stars = search[:min_stars]
    end
    @visibility = params[:visibility] || 'owner'
    @advanced_filter_active = params[:advancedFilterActive]
  end

  def restore_search_params
    search_params = session.delete(:task_search_params)&.symbolize_keys || {}
    %i[search advancedFilterActive page min_stars].each do |key|
      params[key] ||= search_params[key]
    end
  end

  def save_search_params
    session[:task_search_params] = {search: params[:search], advancedFilterActive: params[:advancedFilterActive], page: params[:page]}
  end

  def handle_search_params
    restore_search_params
    save_search_params
  end

  def file_params
    %i[id content attachment path name internal_description mime_type use_attached_file used_by_grader visible usage_by_lms _destroy]
  end

  def test_params
    [:id, :title, :description, :internal_description, :test_type, :xml_id, :validity, :timeout, :_destroy,
     {files_attributes: file_params}]
  end

  def model_solution_params
    [:id, :description, :internal_description, :xml_id, :_destroy, {files_attributes: file_params}]
  end

  def task_params
    params.require(:task).permit(:title, :description, :internal_description, :parent_uuid, :language,
                                 :programming_language_id, files_attributes: file_params, tests_attributes: test_params,
                                                           model_solutions_attributes: model_solution_params)
  end

  def import_confirm_params
    params.permit(:import_id, :subfile_id, :import_type)
  end

  def user_for_api_request
    authorization_header = request.headers['Authorization']
    api_key = authorization_header&.split(' ')&.second
    user_by_api_key(api_key)
  end

  def user_by_api_key(api_key)
    AccountLink.find_by(api_key: api_key)&.user
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
                     locals: {task: task, exported: exported, error: error, task_found: task_found,
                              update_right: update_right})
  end
end
