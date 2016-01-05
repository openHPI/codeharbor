require 'rails_helper'

RSpec.describe "account_links/edit", type: :view do
  before(:each) do
    @account_link = assign(:account_link, AccountLink.create!())
  end

  it "renders the edit account_link form" do
    render

    assert_select "form[action=?][method=?]", account_link_path(@account_link), "post" do
    end
  end
end
