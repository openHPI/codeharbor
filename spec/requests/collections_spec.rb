require 'rails_helper'

RSpec.describe "Collections", type: :request do
  context 'logged in' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      post_via_redirect login_path, :email => @user.email, :password => @user.password
    end

    describe "GET /collections" do
      it "works! (now write some real specs)" do
        get collections_path
        expect(response).to have_http_status(200)
      end
    end
  end
end
