require 'rails_helper'

RSpec.describe "answers/index", type: :view do
  before(:each) do
    assign(:answers, [
      Answer.create!(),
      Answer.create!()
    ])
  end

  it "renders a list of answers" do
    render
  end
end
