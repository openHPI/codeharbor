require 'rails_helper'

RSpec.describe "file_types/show", type: :view do
  before(:each) do
    @file_type = assign(:file_type, FileType.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
