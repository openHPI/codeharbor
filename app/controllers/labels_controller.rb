# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied, ActiveRecord::RecordNotFound do |_exception|
    redirect_to root_path, alert: t('controllers.authorization')
  end

  def search
    @labels = Label.order(:name)
  end
end
