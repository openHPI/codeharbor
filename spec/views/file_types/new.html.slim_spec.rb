require 'rails_helper'

RSpec.describe "file_types/new", type: :view do
  before(:each) do
    assign(:file_type, FileType.new())
  end

  it "renders new file_type form" do
    render

    assert_select "form[action=?][method=?]", file_types_path, "post" do
    end
  end
end
