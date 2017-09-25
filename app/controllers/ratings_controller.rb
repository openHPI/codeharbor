class RatingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise
  before_action :set_rating, only: [:show, :edit, :update, :destroy]
  after_action :update_avg_rating, only: [:create, :update, :destroy]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized to rate.'
  end

  # GET /ratings
  # GET /ratings.json
  def index
    @ratings = Rating.all
  end

  # GET /ratings/1
  # GET /ratings/1.json
  def show
  end

  # GET /ratings/new
  def new
    @rating = Rating.new
  end

  # GET /ratings/1/edit
  def edit
  end

  # POST /ratings
  # POST /ratings.json
  def create
    rating = @exercise.ratings.find_by(user: current_user)
    notice = 'Rating was successfully created.'
    if rating
      notice = 'Rating was successfully updated.'
      rating.update(rating_params)
    else
      rating = Rating.new(rating_params)
    end
    rating.exercise = @exercise
    rating.user = current_user
    flash[:notice] = notice

    respond_to do |format|
      if rating.save
        overall_rating = @exercise.round_avg_rating
        format.json { render json: {overall_rating: overall_rating, user_rating: rating} }
      else
        format.json {render :layout => false, notice: "An Error occured"}
      end
    end
  end

  # PATCH/PUT /ratings/1
  # PATCH/PUT /ratings/1.json
  def update
    respond_to do |format|
      if @rating.update(rating_params)
        format.html { redirect_to @rating, notice: 'Rating was successfully updated.' }
        format.json { render :show, status: :ok, location: @rating }
      else
        format.html { render :edit }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ratings/1
  # DELETE /ratings/1.json
  def destroy
    @rating.destroy
    respond_to do |format|
      format.html { redirect_to ratings_url, notice: 'Rating was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def update_avg_rating
    if @exercise.ratings.empty?
      avg_rating = 0.0
    else
      result = 1.0 * @exercise.ratings.map(&:rating).inject(:+) / @exercise.ratings.size
      avg_rating = result.round(1)
    end

    @exercise.update(avg_rating: avg_rating)

  end

  def set_rating
      @rating = Rating.find(params[:id])
    end

    def set_exercise
      @exercise = Exercise.find(params[:exercise_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rating_params
      params.require(:rating).permit(:rating, :exercise_id, :user_id)
    end
end
