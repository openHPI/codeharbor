# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Test do
  describe 'validations' do
    it { is_expected.to belong_to(:task) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:xml_id) }
    it { is_expected.to validate_uniqueness_of(:xml_id).scoped_to(:task_id) }

    context 'when it has a parent' do
      let(:task) { create(:task, parent_uuid: p_uuid) }
      let(:parent_task) { create(:task) }
      let(:p_uuid) { nil }
      let!(:parent_test) { create(:test, task: parent_task) }
      let(:test) { build(:test, task:, parent_id: parent_test.id) }

      context 'when task has no parent' do
        it 'is not valid' do
          expect(test).not_to be_valid
        end
      end

      context 'when task has different parent' do
        let(:p_uuid) { create(:task).uuid }

        it 'is not valid' do
          expect(test).not_to be_valid
        end
      end

      context 'when task has matching parent' do
        let(:p_uuid) { parent_task.uuid }

        it 'is valid' do
          expect(test).to be_valid
        end
      end
    end
  end

  describe '#duplicate' do
    subject(:duplicate) { test.duplicate }

    let(:test) { create(:test, task: create(:task), files: build_list(:task_file, 2, :exportable)) }

    it 'creates a new test' do
      expect(duplicate).not_to be test
    end

    it 'has the same attributes' do
      expect(duplicate).to have_attributes(test.attributes.except('created_at', 'updated_at', 'id', 'fileable_id'))
    end

    it 'creates new files' do
      expect(duplicate.files).not_to match_array test.files
    end

    it 'creates new files with the same attributes' do
      expect(duplicate.files).to match_array(test.files.map do |file|
                                               have_attributes(file.attributes.except('created_at', 'updated_at', 'id', 'fileable_id'))
                                             end)
    end
  end
end
