require 'rails_helper'

RSpec.describe "messages/index", type: :view do
  before(:each) do
    assign(:messages, [
      Message.create!(
        :text => "Text",
        :sender => nil,
        :recipient => nil,
        :status => "Status"
      ),
      Message.create!(
        :text => "Text",
        :sender => nil,
        :recipient => nil,
        :status => "Status"
      )
    ])
  end

  it "renders a list of messages" do
    render
    assert_select "tr>td", :text => "Text".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
  end
end
