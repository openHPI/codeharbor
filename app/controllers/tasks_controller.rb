# frozen_string_literal: true

require 'zip'

class TasksController < ApplicationController
  load_and_authorize_resource

  before_action :handle_search_params, only: :index
  before_action :set_search, only: [:index]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.exercise.authorization')
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
end
