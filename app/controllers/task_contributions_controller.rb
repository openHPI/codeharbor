# frozen_string_literal: true

class TaskContributionsController < ApplicationController
  include TaskParameters

  before_action :load_and_authorize_task, except: %i[show edit]
  before_action :load_and_authorize_task_contribution, except: %i[create new]

  def approve_changes
    if @task.apply_contribution(@task_contribution)
      TaskContributionMailer.approval_info(@task_contribution).deliver_later
      redirect_to @task, notice: t('.success')
    else
      redirect_to [@task, @task_contribution], alert: t('.error')
    end
  end

  def discard_changes
    if @task_contribution.close
      TaskContributionMailer.rejection_info(@task_contribution).deliver_later
      self_closed = @task_contribution.user == current_user
      redirect_to [@task, (self_closed ? @task_contribution : nil)], notice: t('.success')
    else
      redirect_to [@task, @task_contribution], alert: t('.error')
    end
  end

  def show
    @task = @task_contribution.suggestion

    @files = @task.files
    @tests = @task.tests
    @model_solutions = @task.model_solutions

    @user_rating = @task.ratings&.find_by(user: current_user)&.rating
    render 'tasks/show'
  end

  def new
    @task_contribution = TaskContribution.new_for(@task, current_user)
    authorize @task_contribution

    @task = @task_contribution.suggestion
    render 'tasks/new'
  end

  # The function should render the edit form used by TaskController
  def edit
    @task = @task_contribution.suggestion
    render 'tasks/edit'
  end

  def create
    @task_contribution = TaskContribution.new(suggestion_attributes: task_params, base: @task)
    @task_contribution.suggestion.assign_attributes(user: current_user, access_level: :private)
    authorize @task_contribution

    if @task_contribution.save(context: :force_validations)
      TaskContributionMailer.contribution_request(@task_contribution).deliver_later
      redirect_to [@task, @task_contribution], notice: t('.success')
    else
      redirect_to @task, alert: t('.error')
    end
  end

  def update
    @task_contribution.suggestion.assign_attributes(task_params.except(:parent_uuid))
    if @task_contribution.save(context: :force_validations)
      redirect_to [@task, @task_contribution], notice: t('.success')
    else
      @task = @task_contribution.suggestion
      render 'tasks/edit'
    end
  end

  private

  def load_and_authorize_task
    @task = Task.find(params[:task_id])
    authorize @task, :show?
  end

  def load_and_authorize_task_contribution
    @task_contribution = TaskContribution.find(params[:id])
    authorize @task_contribution
  end
end
