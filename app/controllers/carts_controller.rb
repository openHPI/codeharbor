require 'zip'

class CartsController < ApplicationController
  load_and_authorize_resource
  before_action :set_cart, only: [:show, :edit, :update, :destroy, :remove_exercise, :remove_all, :download_all]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.carts.authorization')
  end
  # GET /carts
  # GET /carts.json
  def index
    @carts = Cart.all
  end

  # GET /carts/1
  # GET /carts/1.json
  def show
  end

  # GET /carts/new
  def new
    @cart = Cart.new
  end

  # GET /carts/1/edit
  def edit
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new
    @cart.user = current_user

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: t('controllers.carts.created') }
        format.json { render :show, status: :created, location: @cart }
      else
        format.html { render :new }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /carts/1
  # PATCH/PUT /carts/1.json
  def update
    respond_to do |format|
      if @cart.update(user: @user)
        format.html { redirect_to carts_path, notice: t('controllers.carts.updated')}
        format.json { render :index, status: :ok, location: @cart }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart.destroy
    respond_to do |format|
      format.html { redirect_to carts_url, notice: t('controllers.carts.destroyed')}
      format.json { head :no_content }
    end
  end

  def remove_exercise
    if @cart.remove_exercise(params[:exercise])
      redirect_to @cart, notice: t('controllers.carts.remove_exercise_success')
    else
      redirect_to @cart, alert: t('controllers.carts.remove_exercise_fail')
    end
  end

  def remove_all
    if @cart.remove_all
      redirect_to @cart, notice: t('controllers.carts.remove_all_success')
    else
      redirect_to @cart, alert: t('controllers.carts.remove_all_fail')
    end
  end

  def download_all
    filename = t('controllers.carts.zip')

    #This is the tricky part
    #Initialize the temp file as a zip file

    stringio = Zip::OutputStream.write_buffer do |zio|
      @cart.exercises.each do |exercise|
        zio.put_next_entry("#{exercise.title}.xml")
        zio.write exercise.to_proforma_xml
      end
    end
    binary_data = stringio.string

    send_data(binary_data, :type => 'application/zip', :filename => filename)

  end

  def my_cart
    unless @cart = Cart.find_by(user: current_user)
      Cart.create(user: current_user)
    end
    redirect_to cart_path(@cart)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = Cart.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
end
