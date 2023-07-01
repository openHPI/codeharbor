# frozen_string_literal: true

require 'rails_helper'

describe 'LabelsController', js: true do
  let(:admin) { create(:admin) }
  let(:password) { attributes_for(:admin)[:password] }

  before do
    sign_in_with_js_driver(admin, password)
  end

  describe '#index' do
    context 'when using name filter' do
      let!(:matching_labels) { [create(:label, name: 'Loops'), create(:label, name: 'Java loops')] }
      let!(:not_matching_labels) { [create(:label, name: 'label1'), create(:label, name: 'python for loop')] }

      it 'filters by name correctly' do
        visit(labels_path)
        fill_in id: 'label-name-filter-input', with: 'loops'
        find('input', id: 'label-name-filter-input').send_keys(:enter)
        wait_for_ajax
        matching_labels.each {|label| expect(page).to have_selector('.labels-table > tbody > tr > td > .task_label', text: label.name) }
        not_matching_labels.each {|label| expect(page).not_to have_selector('.labels-table > tbody > tr > td > .task_label', text: label.name) }
      end
    end

    context 'when merging labels' do
      let!(:labels) { create_list(:label, 5) }
      let(:new_name) { 'new label name' }

      context 'when only renaming one label' do
        subject(:renaming_action) do
          visit(labels_path)
          wait_for_ajax
          find('.labels-table > tbody > tr > td > .task_label', text: labels[1].name).click
          fill_in('merge-labels-input', with: new_name)
          accept_prompt do
            click_button('merge-labels-button')
          end
          wait_for_ajax
        end

        it 'renames the label' do
          renaming_action
          expect(Label.find_by(name: new_name)).not_to be_nil
        end

        it 'does not change the number of labels' do
          expect { renaming_action }.not_to change(Label, :count)
        end
      end

      context 'when merging multiple labels' do
        subject(:merge_action) do
          visit(labels_path)
          wait_for_ajax
          find('.labels-table > tbody > tr > td > .task_label', text: labels[1].name).click
          find('.labels-table > tbody > tr > td > .task_label', text: labels[2].name).click
          fill_in('merge-labels-input', with: new_name)
          accept_prompt do
            click_button('merge-labels-button')
          end
          wait_for_ajax
        end

        let!(:task) { create(:task, labels: labels[1..3]) }

        before { merge_action }

        it 'deletes the old labels' do
          expect(Label.all).not_to include labels[1], labels[2]
        end

        it 'creates the new label' do
          expect(Label.find_by(name: new_name)).not_to be_nil
        end

        it 'updates the tasks' do
          expect(task.reload.labels).not_to include labels[1], labels[2]
          expect(task.reload.label_names).to include new_name
        end
      end
    end

    context 'when deleting labels' do
      subject(:deletion_action) do
        visit(labels_path)
        wait_for_ajax
        find('.labels-table > tbody > tr > td > .task_label', text: labels[1].name).click
        accept_prompt do
          click_button('delete-labels-button')
        end
        wait_for_ajax
      end

      let!(:labels) { create_list(:label, 5) }
      let!(:task) { create(:task, labels: labels[1..3]) }

      it 'deletes the label' do
        deletion_action
        expect(Label.find_by(id: labels[1].id)).to be_nil
      end

      it 'removes the label from tasks' do
        deletion_action
        expect(task.reload.labels).not_to include labels[1]
      end
    end

    context 'when recoloring labels' do
      subject(:recolor_action) do
        visit(labels_path)
        wait_for_ajax
        find('.labels-table > tbody > tr > td > .task_label', text: labels[1].name).click
        find('.labels-table > tbody > tr > td > .task_label', text: labels[2].name).click
        fill_in id: 'color-labels-input', with: '#000000'
        accept_prompt do
          click_button('change-label-color-button')
        end
        wait_for_ajax
      end

      let!(:labels) { create_list(:label, 5) }

      it 'changes the color' do
        recolor_action
        expect(Label.find_by(id: labels[1].id).color).to eq '000000'
        expect(Label.find_by(id: labels[2].id).color).to eq '000000'
      end
    end
  end
end
