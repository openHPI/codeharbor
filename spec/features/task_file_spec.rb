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
        expect(page).to have_content("#{Task.human_attribute_name('language')} #{I18n.t('activerecord.errors.models.task.attributes.language.not_de_or_us')}")
        expect(page).to have_css('.btn.btn-light.border-right-0.disabled', text: file.attachment.filename)
        expect(page).to have_content(I18n.t('tasks.nested_file_form.add_file'))

        # Fix language error and test for unchanged file
        fill_in id: 'task_language', with: 'en'
        click_on(I18n.t('common.button.save_object', model: TaskContribution.model_name.human))
        expect(page).to have_content(I18n.t('common.notices.object_created', model: TaskContribution.model_name.human))
        expect(page).to have_content('New title')
        expect(page).to have_css('.table-header.toggle-next', text: file.name)
        find('.table-header.toggle-next', text: file.name).click
        expect(page).to have_css('.col.row-label', text: I18n.t('activerecord.attributes.task_file.attachment'))
        # We check for the file name of the attached ActiveStorage blob. This file name is the original, unchanged name of the uploaded file shown as image.
        expect(page).to have_css('img[src$="red.bmp"]')
      end
    end

    context 'when a file is changed' do
      let(:text_file_name) { 'example-filename.txt' }

      it 'does not set the parent blob' do
        # Setup and verification
        visit(new_task_task_contribution_path(task))
        fill_in id: 'task_language', with: ''
        fill_in id: 'task_title', with: 'New title'
        attach_file('task_files_attributes_0_attachment', 'spec/fixtures/files/example-filename.txt', visible: false)
        click_on(I18n.t('common.button.save_object', model: TaskContribution.model_name.human))
        # Since the file has ben changed, we expect that the file input is cleared.
        # A user is expected to re-select the file and upload it "again".
        expect(page).to have_content("#{Task.human_attribute_name('language')} #{I18n.t('activerecord.errors.models.task.attributes.language.not_de_or_us')}")
        expect(page).to have_field('task_files_attributes_0_attachment', with: '')

        # Fix language error, leave a blank (invalid) attachment.
        fill_in id: 'task_language', with: 'en'
        click_on(I18n.t('common.button.save_object', model: TaskContribution.model_name.human))
        expect(page).to have_content("#{TaskFile.human_attribute_name('attachment')} can't be blank")

        # Re-select file for upload and expect the new attachment to be present
        attach_file('task_files_attributes_0_attachment', 'spec/fixtures/files/example-filename.txt', visible: false)
        click_on(I18n.t('common.button.save_object', model: TaskContribution.model_name.human))
        expect(page).to have_content(I18n.t('common.notices.object_created', model: TaskContribution.model_name.human))
        find('.table-header.toggle-next', text: text_file_name).click
        expect(page).to have_css('.col.row-label', text: I18n.t('activerecord.attributes.task_file.attachment'))
        # We check for the file name of the attached ActiveStorage blob. This file name is the original, unchanged name of the uploaded file.
        expect(page).to have_link(text_file_name)
      end
    end
  end
end
