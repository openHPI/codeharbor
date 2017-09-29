class CommentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise, except: [:comments_all]
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized to comment.'
  end

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

    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.exercise = @exercise
    @comments = Comment.where(exercise: @exercise).order('created_at DESC')
    respond_to do |format|
      if @comment.save
        format.html { redirect_to exercise_comments_path(@exercise), notice: 'Comment was successfully created.' }
        format.json { render :index, status: :created, location: @collection }
        format.js {render 'exercises/load_comments.js.erb'}
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
        flash[:alert] = "An error ocurred while creating your comment."
        format.js {render :nothing => true, :status => 200}
      end
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
    @comments = Comment.where(exercise: @exercise).search(params[:search]).paginate(per_page: 5, page: params[:page])
  end

  def comments_all
    @comments = Comment.all
  end

  def answer
    redirect_to new_exercises_comments_answers_path(@exercise, @comment)
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
