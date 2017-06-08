class FileTypesController < ApplicationController
  # GET /groups
  # GET /groups.json

  def search
    @file_types = FileType.all
    respond_to do |format|
      format.html
      format.json { render json: @file_types.where('type ilike ?', "%#{params[:term]}%") }
    end
  end
end
