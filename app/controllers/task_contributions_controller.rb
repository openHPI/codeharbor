# frozen_string_literal: true

class TaskContributionsController < ApplicationController
  include TaskParameters

  before_action :load_and_authorize_base_task
  before_action :load_and_authorize_task_contribution, except: %i[index create new]

  def approve_changes
    if @task.apply_contribution(@task_contribution)
      TaskContributionMailer.send_approval_info(@task_contribution).deliver_later
      redirect_to @task, notice: t('.success')
    else
      redirect_to [@task, @task_contribution], alert: t('.error')
    end
  end

  def discard_changes
    duplicate = @task_contribution.decouple
    if duplicate
      redirect_to duplicate, notice: t('.success')
    else
      redirect_to [@task, @task_contribution], alert: t('.error')
    end
  end

  def reject_changes
    duplicate = @task_contribution.decouple
    if duplicate
      TaskContributionMailer.send_rejection_info(@task_contribution, duplicate).deliver_later
      redirect_to @task, notice: t('.success')
    else
      redirect_to [@task, @task_contribution], alert: t('.error')
    end
  end

  def index
    authorize @task, :edit?
    @task_contributions = @task.contributions
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
    raise Pundit::NotAuthorizedError if current_user.nil?

    @task_contribution = TaskContribution.new_for(@task, current_user)
    authorize @task_contribution

    @task = @task_contribution.suggestion
  end

  # The function should render the edit form used by TaskController
  def edit
    @task = @task_contribution.suggestion
    render 'tasks/edit'
  end

  def create # rubocop:disable Metrics/AbcSize
    @task_contribution = TaskContribution.new(suggestion_attributes: task_params, base: @task)
    @task_contribution.suggestion.assign_attributes(
      user: current_user,
      access_level: :private,
      meta_data: @task.meta_data,
      submission_restrictions: @task.submission_restrictions,
      external_resources: @task.external_resources,
      grading_hints: @task.grading_hints
    )
    # TODO: Write a test, ensuring that the four previously-added dachsfisch-data are correctly set for a new contrib
    # TODO: Ensure that accepting the task contrib also updates the four attributes (if changed)
    authorize @task_contribution

    if @task_contribution.save(context: :force_validations)
      TaskContributionMailer.send_contribution_request(@task_contribution).deliver_later
      redirect_to [@task, @task_contribution], notice: t('common.notices.object_created', model: TaskContribution.model_name.human)
    else
      redirect_to @task, alert: t('common.errors.model_not_saved', model: TaskContribution.model_name.human)
    end
  end

  def update
    @task_contribution.suggestion.assign_attributes(task_params.except(:parent_uuid))
    if @task_contribution.save(context: :force_validations)
      redirect_to [@task, @task_contribution], notice: t('common.notices.object_updated', model: TaskContribution.model_name.human)
    else
      @task = @task_contribution.suggestion
      render 'tasks/edit', danger: t('common.errors.changes_not_saved', model: TaskContribution.model_name.human)
    end
  end

  private

  def load_and_authorize_base_task
    @task = Task.find(params[:task_id])
    authorize @task, :show?
  end

  def load_and_authorize_task_contribution
    @task_contribution = TaskContribution.find(params[:id])
    raise Pundit::NotAuthorizedError unless @task_contribution.base == @task

    authorize @task_contribution
  end
end
