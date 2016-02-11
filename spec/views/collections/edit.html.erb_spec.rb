require 'rails_helper'

RSpec.describe "collections/edit", type: :view do
  before(:each) do
    @collection = assign(:collection, Collection.create!(
      :user => nil
    ))
  end

  it "renders the edit collection form" do
    render

    assert_select "form[action=?][method=?]", collection_path(@collection), "post" do

      assert_select "input#collection_user_id[name=?]", "collection[user_id]"
    end
  end
end
