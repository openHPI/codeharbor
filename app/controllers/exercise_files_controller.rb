# frozen_string_literal: true

class ExerciseFilesController < ApplicationController
  load_and_authorize_resource
  before_action :set_exercise_file, only: %i[download_attachment]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized to for this action.'
  end

  def download_attachment
    redirect_to rails_blob_path(@exercise_file.attachment, disposition: 'attachment')
    # send_file @exercise_file.attachment.path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_exercise_file
    @exercise_file = ExerciseFile.find(params[:exercise_file_id])
  end
end
