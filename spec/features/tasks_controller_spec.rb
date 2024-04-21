# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TasksController', :js do
  let(:user) { create(:user) }
  let(:password) { attributes_for(:user)[:password] }

  before do
    sign_in_with_js_driver(user, password)
  end

  describe '#new' do
    before { visit(new_task_path) }

    context 'with invalid params' do
      let(:not_existing_label_name) { 'some new label' }

      it 'displays labels after invalid submission attempt' do
        input = find('select', id: 'task_label_names').sibling('span', class: 'select2').find('textarea')
        input.click # Open select2 dropdown, set focus
        input.send_keys(not_existing_label_name) # Enter label name
        # Assert the label is showing up as a search result. This will implicitly wait for the search (and AJAX calls) to complete.
        expect(page).to have_css('div.task_label', text: not_existing_label_name, visible: :all)
        input.send_keys(:enter) # Select the first option.
        input.click # Close select2 dropdown
        # Assert the label is showing up as a selected label. This will implicitly wait, too.
        expect(page).to have_css("ul li[title=\"#{not_existing_label_name}\"", visible: :all)
        click_on(I18n.t('tasks.form.button.save_task'))
        expect(page).to have_css("option[value=\"#{not_existing_label_name}\"][selected=\"selected\"]", visible: :all)
      end
    end
  end
end
