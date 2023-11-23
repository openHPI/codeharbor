# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskContribution do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:org_user) { create(:user) }
    let(:new_user) { create(:user) }
    let(:access_level) { 'public' }
    let(:org_task) { create(:task, user: org_user, access_level:) }
    let(:task) { create(:task, user: new_user, parent_uuid: org_task.uuid) }
    let(:contribution) { build(:task_contribution, modifying_task: task) }

    context 'when user is contribution user' do
      let(:user) { new_user }

      context 'when access_level is private' do
        let(:access_level) { 'private' }

        it { is_expected.not_to be_able_to(:create, contribution) }
      end

      context 'when access_level is public' do
        let(:access_level) { 'public' }

        context 'when no contribution is created yet' do
          it { is_expected.to be_able_to(:create, contribution) }
        end

        context 'when contribution is created' do
          let(:contribution) { create(:task_contribution, modifying_task: task) }

          it { is_expected.not_to be_able_to(:create, contribution) }
          it { is_expected.to be_able_to(:show, contribution) }
          it { is_expected.to be_able_to(:discard_changes, contribution) }
          it { is_expected.to be_able_to(:destroy, contribution) }
        end
      end
    end

    context 'when user is original user' do
      let(:user) { org_user }

      context 'when there is no contribution' do
        it { is_expected.not_to be_able_to(:create, contribution) }
      end

      context 'when the contribution exists' do
        let(:user) { org_user }
        let(:status) { 'pending' }
        let!(:contribution) { create(:task_contribution, modifying_task: task, status:) }

        context 'when status is pending' do
          let(:status) { 'pending' }

          it { is_expected.not_to be_able_to(:create, contribution) }
          it { is_expected.to be_able_to(:show, contribution) }
          it { is_expected.to be_able_to(:discard_changes, contribution) }
          it { is_expected.to be_able_to(:approve_changes, contribution) }
          it { is_expected.to be_able_to(:show, task) }

          it { is_expected.not_to be_able_to(:update, task) }
          it { is_expected.not_to be_able_to(:destroy, task) }
        end

        context 'when status is closed' do
          let(:status) { 'closed' }

          it { is_expected.not_to be_able_to(:discard_changes, contribution) }
          it { is_expected.not_to be_able_to(:approve_changes, contribution) }
          it { is_expected.not_to be_able_to(:show, task) }

          it { is_expected.not_to be_able_to(:update, task) }
          it { is_expected.not_to be_able_to(:destroy, task) }
        end
      end
    end
  end
end
