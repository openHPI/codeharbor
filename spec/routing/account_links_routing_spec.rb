require "rails_helper"

RSpec.describe AccountLinksController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/account_links").to route_to("account_links#index")
    end

    it "routes to #new" do
      expect(:get => "/account_links/new").to route_to("account_links#new")
    end

    it "routes to #show" do
      expect(:get => "/account_links/1").to route_to("account_links#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/account_links/1/edit").to route_to("account_links#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/account_links").to route_to("account_links#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/account_links/1").to route_to("account_links#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/account_links/1").to route_to("account_links#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/account_links/1").to route_to("account_links#destroy", :id => "1")
    end

  end
end
