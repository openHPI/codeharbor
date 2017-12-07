require 'rails_helper'

RSpec.describe "file_types/edit", type: :view do
  before(:each) do
    @file_type = assign(:file_type, FileType.create!())
  end

  it "renders the edit file_type form" do
    render

    assert_select "form[action=?][method=?]", file_type_path(@file_type), "post" do
    end
  end
end
