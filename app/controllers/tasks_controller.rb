# frozen_string_literal: true

require 'zip'

class TasksController < ApplicationController
  load_and_authorize_resource

  before_action :set_search, only: [:index]
  before_action :handle_search_params, only: :index

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.exercise.authorization')
  end

  def index
    @option = params[:option]
    @created_before_days = params[:q][:created_before_days]
    @dropdown = params[:dropdownWindowActive]

    page = params[:page]
    @q = Task.visibility(@option, current_user).ransack(params[:q])
    @tasks = @q.result(distinct: true).paginate(per_page: 5, page: page)
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
