require 'rails_helper'

RSpec.describe "messages/new", type: :view do
  before(:each) do
    assign(:message, Message.new(
      :text => "MyString",
      :sender => nil,
      :recipient => nil,
      :status => "MyString"
    ))
  end

  it "renders new message form" do
    render

    assert_select "form[action=?][method=?]", messages_path, "post" do

      assert_select "input#message_text[name=?]", "message[text]"

      assert_select "input#message_sender_id[name=?]", "message[sender_id]"

      assert_select "input#message_recipient_id[name=?]", "message[recipient_id]"

      assert_select "input#message_status[name=?]", "message[status]"
    end
  end
end
