# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentPolicy do
  subject { described_class.new(user, comment) }

  let(:user) { nil }
  let(:comment_user) { create(:user) }
  let(:task_user) { create(:user) }
  let(:access_level) { :private }
  let(:task) { create(:task, access_level:, user: task_user) }
  let(:comment) { create(:comment, user: comment_user, task:) }

  context 'when the user can access the comments task' do
    let(:access_level) { :public }

    context 'without a user' do
      it { is_expected.to permit_only_actions(%i[index]) }
    end

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to permit_only_actions(%i[index new]) }

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to permit_all_actions }
      end

      context 'when comment is from user' do
        let(:comment_user) { user }

        it { is_expected.to permit_all_actions }
      end
    end
  end

  context 'when the user cannot access the task' do
    let(:access_level) { :private }

    context 'without a user' do
      it { is_expected.to forbid_all_actions }
    end

    context 'with a user' do
      let(:user) { create(:user) }

      context 'when comment is from user' do
        let(:comment_user) { user }

        it { is_expected.to permit_only_actions(%i[new]) }
      end

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to permit_all_actions }
      end
    end
  end
end
