# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LabelsController', :js do
  let(:admin) { create(:admin) }
  let(:password) { attributes_for(:admin)[:password] }

  before do
    sign_in_with_js_driver(admin, password)
  end

  describe '#index' do
    context 'when using the name filter' do
      let!(:matching_labels) { [create(:label, name: 'Loops'), create(:label, name: 'Java loops')] }
      let!(:not_matching_labels) { [create(:label, name: 'label1'), create(:label, name: 'python for loop')] }

      it 'filters by name correctly' do
        visit(labels_path)
        fill_in id: 'label-name-filter-input', with: 'loops'
        find('input', id: 'label-name-filter-input').send_keys(:enter)
        wait_for_ajax
        matching_labels.each {|label| expect(page).to have_css('.labels-table .task_label', text: label.name) }
        not_matching_labels.each {|label| expect(page).to have_no_css('.labels-table .task_label', text: label.name) }
      end
    end

    context 'when merging labels' do
      let!(:labels) { create_list(:label, 5) }
      let(:new_name) { 'new label name' }
      let(:selected_label) { labels.second }

      context 'when only renaming one label' do
        subject(:renaming_action) do
          visit(labels_path)
          wait_for_ajax
          find('.labels-table .task_label', text: selected_label.name).click
          fill_in('merge-labels-input', with: new_name)
          accept_prompt do
            click_on('merge-labels-button')
          end
          wait_for_ajax
        end

        it 'renames the label' do
          expect { renaming_action }.to change { selected_label.reload.name }.to new_name
        end

        it 'does not change the number of labels' do
          expect { renaming_action }.not_to change(Label, :count)
        end
      end

      context 'when merging multiple labels' do
        subject(:merge_action) do
          visit(labels_path)
          wait_for_ajax
          find('.labels-table .task_label', text: merged_labels.first.name).click
          find('.labels-table .task_label', text: merged_labels.second.name).click
          fill_in('merge-labels-input', with: new_name)
          accept_prompt do
            click_on('merge-labels-button')
          end
          wait_for_ajax
        end

        let!(:task) { create(:task, labels: labels[1..4]) }
        let(:merged_labels) { labels[1..2] }

        it 'renames the first label selected' do
          expect { merge_action }.to change { merged_labels.first.reload.name }.to new_name
        end

        it 'deletes the other labels' do
          merge_action
          expect(Label.where(id: merged_labels.second.id)).not_to exist
        end

        it 'updates the tasks' do
          merge_action
          expect(task.reload.labels).to include merged_labels.first
          expect(task.reload.labels).not_to include merged_labels[1..]
        end
      end
    end

    context 'when deleting labels' do
      subject(:deletion_action) do
        visit(labels_path)
        wait_for_ajax
        find('.labels-table .task_label', text: selected_label.name).click
        accept_prompt do
          click_on('delete-labels-button')
        end
        wait_for_ajax
      end

      let!(:labels) { create_list(:label, 5) }
      let(:selected_label) { labels.second }
      let!(:task) { create(:task, labels: labels[1..3]) }

      it 'deletes the label' do
        deletion_action
        expect(Label.where(id: selected_label.id)).not_to exist
      end

      it 'removes the label from tasks' do
        deletion_action
        expect(task.reload.labels).not_to include selected_label
      end
    end

    context 'when recoloring labels' do
      subject(:recolor_action) do
        visit(labels_path)
        wait_for_ajax
        find('.labels-table .task_label', text: selected_labels.first.name).click
        find('.labels-table .task_label', text: selected_labels.second.name).click
        fill_in id: 'color-labels-input', with: '#000000'
        accept_prompt do
          click_on('change-label-color-button')
        end
        wait_for_ajax
      end

      let!(:labels) { create_list(:label, 5) }
      let(:selected_labels) { labels[1..2] }

      it 'changes the color' do
        recolor_action
        expect(Label.find_by(id: selected_labels.first.id).color).to eq '000000'
        expect(Label.find_by(id: selected_labels.second.id).color).to eq '000000'
      end
    end
  end
end
