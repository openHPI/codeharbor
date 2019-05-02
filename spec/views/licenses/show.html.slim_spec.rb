# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'licenses/show', type: :view do
  before do
    @license = assign(:license, License.create!)
  end

  it 'renders attributes in <p>' do
    render
  end
end
