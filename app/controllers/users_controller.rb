# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = User.all.paginate(per_page: 10, page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end
end
