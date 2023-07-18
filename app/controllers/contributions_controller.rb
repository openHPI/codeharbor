# frozen_string_literal: true

class ContributionsController < ApplicationController
  def approve_changes; end

  def discard_changes; end

  def new
    @task = Task.find(params[:task_id]).clean_duplicate(current_user, false)
    @task.parent_id = params[:task_id]
    task_contrib = TaskContribution.new
    @task.task_contribution = task_contrib
    render 'new'
  end

  def create
    input_task = Task.new(contrib_task_params)
    old_task = Task.find(params[:task_id])
    @task = old_task.clean_duplicate(current_user, false).merge_task(input_task, [], %i[parent_uuid license access_level])

    if @task.save(context: :force_validations)
      redirect_to @task, notice: t('tasks.notification.created')
    else
      redirect_to old_task, alert: t('tasks.notification.duplicate_failed')
    end
  end

  def contrib_task_params
    params.require(:task).permit(:title, :description, :internal_description, :language,
      :programming_language_id, files_attributes: file_params, tests_attributes: test_params,
      model_solutions_attributes: model_solution_params, label_ids: [])
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
