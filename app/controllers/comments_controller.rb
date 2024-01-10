# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :load_and_authorize_task
  before_action :load_and_authorize_comment, only: %i[edit update destroy]
  skip_before_action :require_user!, only: %i[index]

  def index
    @comments = Comment.where(task: @task).paginate(page: params[:page], per_page: per_page_param).order(created_at: :desc)
    authorize @comments, :index? # explicit because index route is rendered in create/update/destroy route on success
    render 'load_comments'
  end

  def edit
    render 'edit_comment'
  end

  def create
    @comment = Comment.new(text: comment_params[:text], user: current_user, task_id: params[:task_id])
    authorize @comment

    if @comment.save
      index
    else
      flash.now[:alert] = t('.error')
      head :ok
    end
  end

  def update
    if @comment.update(comment_params)
      index
    else
      flash.now[:alert] = t('.error')
      head :ok
    end
  end

  def destroy
    @comment.destroy
    index
  end

  private

  def load_and_authorize_task
    @task = Task.find(params[:task_id])
    authorize @task, :show?
  end

  def load_and_authorize_comment
    @comment = Comment.find(params[:id])
    authorize @comment
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def comment_params
    params.require(:comment).permit(:text)
  end
end
