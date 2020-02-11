# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to root_path, alert: 'You are not authorized for this action.'
  end

  def search
    @labels = Label.order(:name)
  end
end
