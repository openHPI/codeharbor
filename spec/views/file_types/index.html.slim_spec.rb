# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'file_types/index', type: :view do
  before do
    allow(view).to receive(:will_paginate)
    assign(:file_types, [
             FileType.create!,
             FileType.create!
           ])
  end

  it 'renders a list of file_types' do
    render
  end
end
