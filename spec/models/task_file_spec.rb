# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskFile do
  describe '#valid?' do
    subject { build(:task_file) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to belong_to(:fileable) }
    it { is_expected.to validate_presence_of(:xml_id) }
    it { is_expected.to validate_inclusion_of(:visible).in_array(%w[yes no delayed]) }

    context 'with task which has another file with the same xml_id' do
      subject(:file) { task.files.first }

      let(:task) { build(:task, files: build_list(:task_file, 2, xml_id: '1')) }

      it 'has correct error' do
        file.validate
        expect(file.errors.full_messages).to include "#{described_class.human_attribute_name('xml_id')} #{I18n.t('activerecord.errors.models.task_file.attributes.xml_id.not_unique')}"
      end
    end

    context 'with task which has a test with another file with the same xml_id' do
      subject(:file) { task.files.first }

      let(:task) { build(:task, files: build_list(:task_file, 1, xml_id: '1'), tests: build_list(:test, 1, files: build_list(:task_file, 1, xml_id: '1'))) }

      it 'has correct error' do
        file.validate
        expect(file.errors.full_messages).to include "#{described_class.human_attribute_name('xml_id')} #{I18n.t('activerecord.errors.models.task_file.attributes.xml_id.not_unique')}"
      end
    end

    context 'with task which has a test with another file with the another xml_id' do
      subject(:file) { task.files.first }

      let(:task) { build(:task, files: build_list(:task_file, 1, xml_id: '1'), tests: build_list(:test, 1, files: build_list(:task_file, 1, xml_id: '2'))) }

      it { is_expected.to be_valid }
    end

    context 'when use_attached_file is true' do
      subject { build(:task_file, :with_attachment, use_attached_file: 'true') }

      it { is_expected.to validate_presence_of(:attachment).on(:force_validations) }
    end

    context 'when use_attached_file is false' do
      subject { build(:task_file, :with_attachment, use_attached_file: 'false') }

      it { is_expected.not_to validate_presence_of(:attachment).on(:force_validations) }
    end
  end

  describe '#full_file_name' do
    subject { file.full_file_name }

    let(:file) { build(:task_file, name: 'filename') }

    it { is_expected.to eql 'filename' }

    context 'with path' do
      let(:file) { build(:task_file, name: 'filename', path: 'folder') }

      it { is_expected.to eql 'folder/filename' }
    end
  end

  describe '#duplicate' do
    subject(:duplicate) { file.duplicate }

    let(:file) { create(:task_file) }

    it 'creates a new file' do
      expect(duplicate).not_to be file
    end

    it 'has the same attributes' do
      expect(duplicate).to have_attributes(file.attributes.except('created_at', 'updated_at', 'id'))
    end
  end

  describe '#remove_attachment hook' do
    let!(:file) { create(:task_file, :with_attachment) }
    let(:use_attached_file) { 'true' }

    before do
      file.use_attached_file = use_attached_file
      file.save
    end

    it 'does not remove attachment on save' do
      expect(file.reload.attachment.present?).to be true
    end

    context 'when use_attached_file is false' do
      let(:use_attached_file) { 'false' }

      it 'removes attachment on save' do
        expect(file.reload.attachment.present?).to be false
      end
    end
  end

  describe '#text_data?' do
    subject { file.text_data? }

    let(:file) { create(:task_file, :with_attachment) }

    it { is_expected.to be false }

    context 'when file has text content' do
      let(:file) { create(:task_file, :with_text_attachment) }

      it { is_expected.to be true }
    end
  end

  describe '#task' do
    subject(:task_result) { task_file.task }

    let(:task) { create(:task) }
    let(:fileable_object) { nil }
    let(:fileable) { fileable_object }
    let(:task_file) { create(:task_file, fileable:) }

    context 'when fileable is Task' do
      let(:fileable_object) { task }

      it 'returns task' do
        expect(task_result).to eq(task)
      end
    end

    context 'when fileable is ModelSolution' do
      let(:fileable_object) { create(:model_solution, task:) }

      it 'returns task' do
        expect(task_result).to eq(task)
      end
    end

    context 'when fileable is Test' do
      let(:fileable_object) { create(:test, task:) }

      it 'returns task' do
        expect(task_result).to eq(task)
      end
    end
  end
end
