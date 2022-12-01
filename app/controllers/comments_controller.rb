# frozen_string_literal: true

class CommentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_task
  before_action :set_comment, only: %i[edit update destroy]
  before_action :new_comment, only: :create

  def index
    @comments = Comment.where(task: @task).paginate(per_page: 5, page: params[:page]).order('created_at DESC')
    render 'load_comments.js.erb'
  end

  def edit
    render 'edit_comment.js.erb'
  end

  def create
    if @comment.save
      index
    else
      flash.now[:alert] = t('controllers.comment.error.create')
      head :ok
    end
  end

  def update
    if @comment.update(comment_params)
      index
    else
      flash.now[:alert] = t('controllers.comment.error.update')
      head :ok
    end
  end

  def destroy
    @comment.destroy
    index
  end

  private

  def new_comment
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.task = @task
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_task
    @task = Task.find(params[:task_id])
  end

  # Never trust parameters from the scary internet, only allow the following list through.
  def comment_params
    params.require(:comment).permit(:text, :task_id, :user_id)
  end
end
