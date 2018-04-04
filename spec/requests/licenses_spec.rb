require 'rails_helper'

RSpec.describe "Licenses", type: :request do
  describe "GET /licenses" do
    it "works! (now write some real specs)" do
      get licenses_path
      expect(response).to have_http_status(200)
    end
  end
end
