# frozen_string_literal: true

class TaskFilesController < ApplicationController
  load_and_authorize_resource
  before_action :set_task_file, only: %i[download_attachment]

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized to for this action.'
  end

  def download_attachment
    redirect_to rails_blob_path(@task_file.attachment, disposition: 'attachment')
  end

  private

  def set_task_file
    @task_file = TaskFile.find(params[:task_file_id])
  end
end
