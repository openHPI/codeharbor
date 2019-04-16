# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'licenses/new', type: :view do
  before do
    assign(:license, License.new)
  end

  it 'renders new license form' do
    render

    assert_select 'form[action=?][method=?]', licenses_path, 'post' do
    end
  end
end
