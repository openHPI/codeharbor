# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskFile do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:task_user) { create(:user) }
    let(:task) { create(:task, user: task_user) }
    let(:fileable) { task }
    let(:task_file) { create(:task_file, fileable: fileable) }

    it { is_expected.not_to be_able_to(:download_attachment, task_file) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.not_to be_able_to(:download_attachment, task_file) }

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, task_file) }
      end

      context 'when task is from user' do
        let(:task_user) { user }

        it { is_expected.to be_able_to(:download_attachment, task_file) }
      end

      context 'when task_file belongs to a test' do
        let(:fileable) { create(:test, task: task) }

        it { is_expected.not_to be_able_to(:download_attachment, task_file) }

        context 'when task is from user' do
          let(:task_user) { user }

          it { is_expected.to be_able_to(:download_attachment, task_file) }
        end
      end
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

    let(:file) { create(:task_file, :with_task) }

    it 'creates a new file' do
      expect(duplicate).not_to be file
    end

    it 'has the same attributes' do
      expect(duplicate).to have_attributes(file.attributes.except('created_at', 'updated_at', 'id'))
    end
  end
end
