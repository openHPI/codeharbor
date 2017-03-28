require 'rails_helper'

RSpec.describe "Carts", type: :request do
  context 'logged in' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      post_via_redirect login_path, :email => @user.email, :password => @user.password
    end
    describe "GET /carts" do
      it "works! (now write some real specs)" do
        get carts_path
        expect(response).to have_http_status(200)
      end
    end
  end
end
