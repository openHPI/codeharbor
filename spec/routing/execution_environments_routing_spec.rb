require "rails_helper"

RSpec.describe ExecutionEnvironmentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/execution_environments").to route_to("execution_environments#index")
    end

    it "routes to #new" do
      expect(:get => "/execution_environments/new").to route_to("execution_environments#new")
    end

    it "routes to #show" do
      expect(:get => "/execution_environments/1").to route_to("execution_environments#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/execution_environments/1/edit").to route_to("execution_environments#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/execution_environments").to route_to("execution_environments#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/execution_environments/1").to route_to("execution_environments#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/execution_environments/1").to route_to("execution_environments#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/execution_environments/1").to route_to("execution_environments#destroy", :id => "1")
    end

  end
end
