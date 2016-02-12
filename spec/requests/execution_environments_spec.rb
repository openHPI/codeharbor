require 'rails_helper'

RSpec.describe "ExecutionEnvironments", type: :request do
  describe "GET /execution_environments" do
    it "works! (now write some real specs)" do
      get execution_environments_path
      expect(response).to have_http_status(200)
    end
  end
end
