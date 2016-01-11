require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "Logins and redirects" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "returns redirection to login" do
      get :destroy
      expect(response).to redirect_to "/login"
    end
  end

end
