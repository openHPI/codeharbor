# frozen_string_literal: true

class ContributionsController < ApplicationController
  load_and_authorize_resource class: TaskContribution, except: %i[create new]
  def approve_changes
    contrib = TaskContribution.find(params[:contribution_id])
    @task = Task.find(params[:task_id])
    if @task.apply_contribution(contrib)
      TaskContributionMailer.approval_info(contrib).deliver_later # TODO: Should it be deliver_now?
      redirect_to @task, notice: t('task_contributions.approve_changes.success')
    else
      redirect_to contrib.modifying_task, alert: t('task_contributions.approve_changes.error')
    end
  end

  # rubocop:disable Metrics/AbcSize
  def discard_changes
    contrib = TaskContribution.find(params[:contribution_id])
    if contrib.close
      TaskContributionMailer.rejection_info(contrib).deliver_later
      path = contrib.modifying_task.user.id == current_user.id ? contrib.modifying_task : Task
      redirect_to path, notice: t('task_contributions.discard_changes.success')
    else
      redirect_to contrib.modifying_task, alert: t('task_contributions.discard_changes.error')
    end
  end
  # rubocop:enable Metrics/AbcSize

  def show
    contrib = TaskContribution.find(params[:id])
    redirect_to contrib.modifying_task
  end

  def new
    @task = Task.find(params[:task_id]).clean_duplicate(current_user, change_title: false)
    @task.parent_id = params[:task_id]
    task_contrib = TaskContribution.new
    @task.task_contribution = task_contrib
    authorize! :new, task_contrib
    render 'new'
  end

  def edit; end

  def create
    @task = Task.new(contrib_task_params)
    contrib = TaskContribution.new(status: :pending)
    @task.task_contribution = contrib
    authorize! :create, contrib
    if @task.save(context: :force_validations)
      TaskContributionMailer.contribution_request(contrib).deliver_later
      redirect_to @task, notice: t('task_contributions.create.success')
    else
      redirect_to Task.find(params[:task_id]), alert: t('task_contributions.create.error')
    end
  end

  def contrib_task_params
    params.require(:task).permit(:title, :description, :internal_description, :language,
      :programming_language_id, files_attributes: file_params, tests_attributes: test_params,
      model_solutions_attributes: model_solution_params, label_ids: [])
      .merge(user: current_user, parent_uuid: Task.find(params[:task_id]).uuid,
        access_level: :private, task_contribution: TaskContribution.new)
  end

  def file_params
    %i[id content attachment path name internal_description mime_type use_attached_file used_by_grader visible usage_by_lms xml_id _destroy
       parent_id]
  end

  def test_params
    [:id, :testing_framework_id, :title, :description, :internal_description, :test_type, :xml_id, :validity, :timeout, :_destroy,
     :parent_id, {files_attributes: file_params}]
  end

  def model_solution_params
    [:id, :description, :internal_description, :xml_id, :_destroy, :parent_id, {files_attributes: file_params}]
  end
end