# frozen_string_literal: true

require 'zip'

class TasksController < ApplicationController
  load_and_authorize_resource except: %i[import_external import_uuid_check]

  before_action :handle_search_params, only: :index
  before_action :set_search, only: [:index]
  skip_before_action :verify_authenticity_token, only: %i[import_external import_uuid_check]

  rescue_from CanCan::AccessDenied do |_exception|
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
    return render json: {task_found: false} if task.nil?
    return render json: {task_found: true, update_right: false} unless task.can_access(user)

    render json: {task_found: true, update_right: true}
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

  private

  def set_search
    search = params[:search]
    @created_before_days = search[:created_before_days] if search.is_a?(ActionController::Parameters)
    @visibility = params[:visibility] || 'owner'
    @advanced_filter_active = params[:advancedFilterActive]
  end

  def restore_search_params
    search_params = session.delete(:exercise_search_params)&.symbolize_keys || {}
    params[:search] ||= search_params[:search]
    params[:advancedFilterActive] ||= search_params[:advancedFilterActive]
    params[:page] ||= search_params[:page]
  end

  def save_search_params
    session[:exercise_search_params] = {search: params[:search], advancedFilterActive: params[:advancedFilterActive], page: params[:page]}
  end

  def handle_search_params
    restore_search_params
    save_search_params
  end

  def file_params
    %i[id content attachment path name internal_description mime_type used_by_grader visible usage_by_lms _destroy]
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
end
