require 'rails_helper'

RSpec.describe "answers/edit", type: :view do
  before(:each) do
    @answer = assign(:answer, Answer.create!())
  end

  it "renders the edit answer form" do
    render

    assert_select "form[action=?][method=?]", answer_path(@answer), "post" do
    end
  end
end
