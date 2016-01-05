require 'rails_helper'

RSpec.describe "account_links/new", type: :view do
  before(:each) do
    assign(:account_link, AccountLink.new())
  end

  it "renders new account_link form" do
    render

    assert_select "form[action=?][method=?]", account_links_path, "post" do
    end
  end
end
