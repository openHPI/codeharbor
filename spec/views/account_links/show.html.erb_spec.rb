require 'rails_helper'

RSpec.describe "account_links/show", type: :view do
  before(:each) do
    @account_link = assign(:account_link, AccountLink.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
