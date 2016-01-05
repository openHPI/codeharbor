require 'rails_helper'

RSpec.describe "account_links/index", type: :view do
  before(:each) do
    assign(:account_links, [
      AccountLink.create!(),
      AccountLink.create!()
    ])
  end

  it "renders a list of account_links" do
    render
  end
end
