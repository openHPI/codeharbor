require 'rails_helper'

RSpec.describe "execution_environments/new", type: :view do
  before(:each) do
    assign(:execution_environment, ExecutionEnvironment.new(
      :language => "MyString",
      :version => "MyString"
    ))
  end

  it "renders new execution_environment form" do
    render

    assert_select "form[action=?][method=?]", execution_environments_path, "post" do

      assert_select "input#execution_environment_language[name=?]", "execution_environment[language]"

      assert_select "input#execution_environment_version[name=?]", "execution_environment[version]"
    end
  end
end
