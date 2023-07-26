# frozen_string_literal: true

class ContributionsController < ApplicationController
  def approve_changes;
    contrib = TaskContribution.find(params[:contribution_id])
    @task = Task.find(params[:task_id])
    contrib_attributes = contrib.task.attributes.except!('parent_uuid', 'access_level', 'user_id', 'uuid', 'id')
    @task.assign_attributes(contrib_attributes)
    @task.transfer_linked_files(contrib.task)
    @task.model_solutions = @task.transfer_multiple(@task.model_solutions, contrib.task.model_solutions, {task_id: @task.id})
    @task.tests = @task.transfer_multiple(@task.tests, contrib.task.tests, {task_id: @task.id})
    contrib.status = :merged
    if @task.save
      redirect_to @task, notice: 'Merged'
    else
      redirect_to contrib.task, alert: 'Merge failed'
    end
  end

  def discard_changes
    contrib = TaskContribution.find(params[:contribution_id])
    contrib.status = :closed
    if contrib.save
      redirect_to contrib.task, notice: t('task_contributions.discard_changes.success')
    else
      redirect_to contrib.task, alert: t('task_contributions.discard_changes.error')
    end
  end

  def new
    @task = Task.find(params[:task_id]).clean_duplicate(current_user, false)
    @task.parent_id = params[:task_id]
    task_contrib = TaskContribution.new
    @task.task_contribution = task_contrib
    render 'new'
  end

  def create
    @task = Task.new(contrib_task_params)
    contrib = TaskContribution.new(status: 0)
    @task.task_contribution = contrib
    if @task.save(context: :force_validations)
      redirect_to @task, notice: t('task_contributions.new.success')
    else
      redirect_to old_task, alert: t('task_contributions.new.error')
    end
  end
  def contrib_task_params
    params.require(:task).permit(:title, :description, :internal_description, :language,
      :programming_language_id, files_attributes: file_params, tests_attributes: test_params,
      model_solutions_attributes: model_solution_params, label_ids: [])
      .merge(user: current_user, parent_uuid: Task.find(params[:task_id]).uuid, access_level: :private, task_contribution: TaskContribution.new)
  end

  def file_params
    %i[id content attachment path name internal_description mime_type use_attached_file used_by_grader visible usage_by_lms xml_id _destroy]
  end

  def test_params
    [:id, :title, :description, :internal_description, :test_type, :xml_id, :validity, :timeout, :_destroy, {files_attributes: file_params}]
  end

  def model_solution_params
    [:id, :description, :internal_description, :xml_id, :_destroy, {files_attributes: file_params}]
  end
end
