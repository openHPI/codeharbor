# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TaskContributionController', :js do
  let(:task) { create(:task, access_level: 'public', files: [file]) }
  let(:file) { create(:task_file, :with_attachment) }
  let(:user) { create(:user) }
  let(:password) { attributes_for(:user)[:password] }

  before do
    sign_in_with_js_driver(user, password)
  end

  describe '.attach_parent_blob' do
    context 'when a file is not changed' do
      it 'sets the parent blob' do
        # Setup and verification
        visit(new_task_task_contribution_path(task))
        fill_in id: 'task_language', with: ''
        fill_in id: 'task_title', with: 'New title'
        click_on(I18n.t('common.button.save_object', model: TaskContribution.model_name.human))
        expect(page).to have_content('Language is not in the correct format.')
        expect(page).to have_css('.btn.btn-light.border-right-0.disabled', text: file.attachment.filename)
        expect(page).to have_content(I18n.t('tasks.nested_file_form.add_file'))
        # Test
        fill_in id: 'task_language', with: 'en'
        click_on(I18n.t('common.button.save_object', model: TaskContribution.model_name.human))
        expect(page).to have_content('Task Contribution has successfully been created.')
        expect(page).to have_content('New title')
        expect(page).to have_css('.table-header.toggle-next', text: file.name)
        expect(page).to have_css('.col.row-label', text: I18n.t('activerecord.attributes.task_file.attachment'))
      end
    end
  end
end
