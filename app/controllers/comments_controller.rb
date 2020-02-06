# frozen_string_literal: true

class CommentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise, except: [:comments_all]
  before_action :set_comment, only: %i[show edit update destroy]
  before_action :new_comment, only: :create

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized to comment.'
  end

  def show; end

  def new
    @comment = Comment.new
  end

  def edit
    respond_to do |format|
      format.js { render 'edit_comment.js.erb' }
    end
  end

  # rubocop:disable Metrics/AbcSize
  def create
    respond_to do |format|
      if @comment.save
        format.json { render :index, status: :created, location: @comment }
        format.js { index }
      else
        format.json { render json: @comment.errors, status: :unprocessable_entity }
        flash[:alert] = 'An error ocurred while creating your comment.'
        format.js { render nothing: true, status: 200 }
      end
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.json { render :show, status: :ok, location: @comment }
        format.js { index }
      else
        format.json { render json: @comment.errors, status: :unprocessable_entity }
        flash[:alert] = 'An error ocurred while updating your comment.'
        format.js { render nothing: true, status: 200 }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    @comment.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.js { index }
    end
  end

  def index
    @comments = Comment.where(exercise: @exercise).paginate(per_page: 5, page: params[:page]).order('created_at DESC')
    respond_to do |format|
      format.js { render 'load_comments.js.erb' }
    end
  end

  private

  def new_comment
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.exercise = @exercise
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_exercise
    @exercise = Exercise.find(params[:exercise_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:text, :exercise_id, :user_id)
  end
end
