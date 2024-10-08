# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskContributionPolicy do
  subject { described_class.new(user, contribution) }

  let(:user) { nil }
  let(:org_user) { create(:user) }
  let(:new_user) { create(:user) }
  let(:access_level) { 'public' }
  let(:org_task) { create(:task, user: org_user, access_level:) }
  let(:contribution_approval_status) { 'pending' }
  let(:contribution) { create(:task_contribution, user: new_user, base: org_task, status: contribution_approval_status) }

  context 'when the user is not logged in' do
    it { expect { described_class.new(nil, contribution) }.to raise_error(Pundit::NotAuthorizedError) }
  end

  context 'when the user is logged in' do
    context 'when the user is the contribution user' do
      let(:user) { new_user }

      context 'when the original task is private' do
        let(:access_level) { 'private' }

        it { is_expected.to permit_only_actions %i[discard_changes show update edit download] }
      end

      context 'when the original task is public' do
        context 'when the user has no contribution for task yet' do
          let(:contribution_approval_status) { 'closed' }

          it { is_expected.to permit_only_actions %i[create new] }
        end

        context 'when the user has a contribution for the task' do
          it { is_expected.to forbid_actions %i[new create approve_changes] }
          it { is_expected.to permit_actions %i[discard_changes show update] }

          context 'when the approval is closed' do # rubocop:disable RSpec/NestedGroups
            let(:contribution_approval_status) { 'closed' }

            it { is_expected.to forbid_actions %i[discard_changes show edit update] }
          end
        end
      end
    end

    context 'when the user own the original task' do
      let(:user) { org_user }

      it { is_expected.to forbid_actions %i[create new update destroy] }

      context 'when the approval is pending' do
        it { is_expected.to permit_only_actions %i[approve_changes reject_changes show download index] }
      end

      context 'when the approval is closed' do
        let(:contribution_approval_status) { 'closed' }

        it { is_expected.to permit_only_actions %i[show download index] }
      end
    end
  end

  it 'specifies all policies also present for a task' do
    contribution_policies = described_class.instance_methods(false).filter {|method| method.ends_with?('?') }
    task_policies = TaskPolicy.instance_methods(false).filter {|method| method.ends_with?('?') }
    expect(contribution_policies).to include(*task_policies),
      'All policies for a task should also be present for a task contribution.' \
      "Please ensure to implement the missing policies #{task_policies - contribution_policies}."
  end
end
