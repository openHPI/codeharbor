# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource
  before_action :set_label, only: %i[show edit update destroy]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized for this action.'
  end

  def index
    @labels = Label.all.paginate(per_page: 10, page: params[:page])
  end

  def show; end

  def new
    @label = Label.new
  end

  def search
    @labels = Label.order(:name)
  end

  def edit; end

  def create
    @label = Label.new(label_params)

    if @label.save
      redirect_to @label, notice: 'Label was successfully created.'
    else
      render :new
    end
  end

  def update
    if @label.update(label_params)
      redirect_to @label, notice: 'Label was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @label.destroy
    redirect_to labels_url, notice: 'Label was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_label
    @label = Label.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def label_params
    params.require(:label).permit(:name)
  end
end
