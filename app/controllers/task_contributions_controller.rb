# frozen_string_literal: true

class TaskContributionsController < ApplicationController
  include TaskParameters
  load_and_authorize_resource class: TaskContribution, except: %i[create new]
  def approve_changes
    contrib = TaskContribution.find(params[:id])
    @task = Task.find(params[:task_id])
    if @task.apply_contribution(contrib)
      TaskContributionMailer.approval_info(contrib).deliver_later
      redirect_to @task, notice: t('.success')
    else
      redirect_to contrib.modifying_task, alert: t('.error')
    end
  end

  def discard_changes
    contrib = TaskContribution.find(params[:id])
    if contrib.close
      TaskContributionMailer.rejection_info(contrib).deliver_later
      path = contrib.modifying_task.user == current_user ? contrib.modifying_task : Task
      redirect_to path, notice: t('.success')
    else
      redirect_to contrib.modifying_task, alert: t('.error')
    end
  end

  def show
    contrib = TaskContribution.find(params[:id])
    @task = contrib.modifying_task
    @files = @task.files
    @tests = @task.tests
    @model_solutions = @task.model_solutions

    @user_rating = @task.ratings&.find_by(user: current_user)&.rating
    render 'tasks/show'
  end

  def new
    @task = Task.find(params[:task_id]).clean_duplicate(current_user, change_title: false)
    @task.parent_id = params[:task_id]
    task_contrib = TaskContribution.new
    @task.task_contribution = task_contrib
    authorize! :new, task_contrib
    render 'new'
  end
  # The function should render the edit form used by TaskController
  def edit
    contrib = TaskContribution.find(params[:id])
    @task = contrib.modifying_task
    render 'tasks/edit'
  end


  def create
    @task = Task.new(contrib_task_params)
    contrib = TaskContribution.new(status: :pending)
    @task.task_contribution = contrib
    authorize! :create, contrib
    if @task.save(context: :force_validations)
      TaskContributionMailer.contribution_request(contrib).deliver_later
      redirect_to @task, notice: t('.success')
    else
      redirect_to Task.find(params[:task_id]), alert: t('.error')
    end
  end

  def contrib_task_params
    task_params
      .merge(user: current_user, parent_uuid: Task.find(params[:task_id]).uuid,
        access_level: :private, task_contribution: TaskContribution.new)
  end
end
