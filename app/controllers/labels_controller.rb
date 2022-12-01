# frozen_string_literal: true

class LabelsController < ApplicationController
  load_and_authorize_resource

  def search
    @labels = Label.order(:name)
  end
end
