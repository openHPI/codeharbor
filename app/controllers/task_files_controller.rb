# frozen_string_literal: true

class TaskFilesController < ApplicationController
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied, ActiveRecord::RecordNotFound do |_exception|
    redirect_to root_path, alert: t('controllers.authorization')
  end

  def download_attachment
    redirect_to rails_blob_path(@task_file.attachment, disposition: 'attachment')
  end

  def extract_text_data
    return render json: {error: I18n.t('controllers.task_file.extract_text_data.no_text')} unless @task_file.text_data?

    render json: {
      text_data: @task_file.extract_text_data,
    }
  end
end
