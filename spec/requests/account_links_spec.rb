require 'rails_helper'

RSpec.describe "AccountLinks", type: :request do
  describe "GET /account_links" do
    it "works! (now write some real specs)" do
      get account_links_path
      expect(response).to have_http_status(200)
    end
  end
end
