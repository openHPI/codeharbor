require 'rails_helper'

RSpec.describe "Carts", type: :request do
  describe "GET /carts" do
    it "works! (now write some real specs)" do
      get carts_path
      expect(response).to have_http_status(200)
    end
  end
end
