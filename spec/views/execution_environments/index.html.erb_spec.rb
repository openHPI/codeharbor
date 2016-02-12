require 'rails_helper'

RSpec.describe "execution_environments/index", type: :view do
  before(:each) do
    assign(:execution_environments, [
      ExecutionEnvironment.create!(
        :language => "Language",
        :version => "Version"
      ),
      ExecutionEnvironment.create!(
        :language => "Language",
        :version => "Version"
      )
    ])
  end

  it "renders a list of execution_environments" do
    render
    assert_select "tr>td", :text => "Language".to_s, :count => 2
    assert_select "tr>td", :text => "Version".to_s, :count => 2
  end
end
