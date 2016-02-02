class CommentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized to comment.'
  end

  # GET /comments
  # GET /comments.json
  # def index
  #   @comments = Comment.all
  # end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    comment = @exercise.comments.find_by(user: current_user)
    notice = 'Comment was successfully created.'
    if comment
      notice = 'Comment was successfully updated.'
      comment.update(comment_params)
    else
      comment = Comment.new(comment_params)
    end
    comment.exercise = @exercise
    comment.user = current_user

    if comment.save
      redirect_to exercise_comments_path(@exercise), notice: notice
    else
      render :new
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to exercise_comments_path(@exercise), notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def index
    @comment = Comment.search(params[:search]).paginate(per_page: 5, page: params[:page])
  end

  private
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
