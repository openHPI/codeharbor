require 'rails_helper'

RSpec.describe "execution_environments/edit", type: :view do
  before(:each) do
    @execution_environment = assign(:execution_environment, ExecutionEnvironment.create!(
      :language => "MyString",
      :version => "MyString"
    ))
  end

  it "renders the edit execution_environment form" do
    render

    assert_select "form[action=?][method=?]", execution_environment_path(@execution_environment), "post" do

      assert_select "input#execution_environment_language[name=?]", "execution_environment[language]"

      assert_select "input#execution_environment_version[name=?]", "execution_environment[version]"
    end
  end
end
