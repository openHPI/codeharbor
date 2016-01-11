require 'rails_helper'

RSpec.describe AccountLinksController, type: :controller do
  describe "Logins and redirects" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      login_with(@user)
    end

    it "returns http success" do
      get :new, { user_id: @user.id }
      expect(response).to have_http_status(:success)
    end
  end
end
