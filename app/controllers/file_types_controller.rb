# frozen_string_literal: true

class FileTypesController < ApplicationController
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: t('controllers.file_type.authorization')
  end

  def search
    @file_types = FileType.all
    respond_to do |format|
      format.html
    end
  end
end
