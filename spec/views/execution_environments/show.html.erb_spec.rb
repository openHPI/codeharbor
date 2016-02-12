require 'rails_helper'

RSpec.describe "execution_environments/show", type: :view do
  before(:each) do
    @execution_environment = assign(:execution_environment, ExecutionEnvironment.create!(
      :language => "Language",
      :version => "Version"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Language/)
    expect(rendered).to match(/Version/)
  end
end
