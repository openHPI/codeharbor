# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'file_types/show', type: :view do
  before do
    @file_type = assign(:file_type, FileType.create!)
  end

  it 'renders attributes in <p>' do
    render
  end
end
