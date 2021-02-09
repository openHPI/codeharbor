# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskFile, type: :model do
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
end
