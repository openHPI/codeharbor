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
        input = find('select', id: 'task_label_names').sibling('span', class: 'select2').find('input')
        input.send_keys(not_existing_label_name)
        wait_for_ajax
        input.send_keys(:enter)
        click_button(I18n.t('tasks.form.button.save_task'))
        expect(page).to have_selector("option[value=\"#{not_existing_label_name}\"][selected=\"selected\"]", visible: :all)
      end
    end
  end
end
