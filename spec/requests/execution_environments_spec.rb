require 'rails_helper'

RSpec.describe "ExecutionEnvironments", type: :request do
  context 'logged in' do
    before(:each) do
      @user = FactoryBot.create(:user)
      post login_path, params: {:email => @user.email, :password => @user.password}
      follow_redirect!
    end

    describe "GET /execution_environments" do
      it "works! (now write some real specs)" do
        get execution_environments_path
        expect(response).to have_http_status(302)
      end
    end
  end
end
