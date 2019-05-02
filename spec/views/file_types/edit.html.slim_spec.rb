# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'file_types/edit', type: :view do
  let!(:file_type) { assign(:file_type, FileType.create!) }

  it 'renders the edit file_type form' do
    render

    assert_select 'form[action=?][method=?]', file_type_path(file_type), 'post' do
    end
  end
end
