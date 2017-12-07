require 'rails_helper'

RSpec.describe "FileTypes", type: :request do
  describe "GET /file_types" do
    it "works! (now write some real specs)" do
      get file_types_path
      expect(response).to have_http_status(200)
    end
  end
end
