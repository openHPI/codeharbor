# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'licenses/edit', type: :view do
  it 'renders the edit license form' do
    license = assign(:license, License.create!)
    render
    assert_select 'form[action=?][method=?]', license_path(license), 'post' do
    end
  end
end
