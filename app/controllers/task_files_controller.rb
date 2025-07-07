# frozen_string_literal: true

class TaskFilesController < ApplicationController
  before_action :load_and_authorize_task_file

  def download_attachment
    redirect_to rails_blob_path(@task_file.attachment, disposition: 'attachment'), status: :see_other
  end

  def extract_text_data
    return render json: {error: t('.no_text')} unless @task_file.text_data?

    render json: {
      text_data: @task_file.extract_text_data,
    }
  end

  private

  def load_and_authorize_task_file
    @task_file = TaskFile.find(params[:id])
    authorize @task_file
  end
end
