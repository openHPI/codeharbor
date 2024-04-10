# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskPolicy do
  subject { described_class.new(user, task) }

  let(:task_user) { create(:user) }
  let(:groups) { [] }
  let(:access_level) { :private }
  let(:task) { create(:task, user: task_user, access_level:, groups:) }
  let(:all_actions) { %i[show download import_uuid_check import_external index new import_start import_confirm create add_to_collection duplicate export_external_start export_external_check export_external_confirm update edit destroy manage contribute] }
  let(:openai_api_key) { nil }

  before do
    allow(GptService::ValidateApiKey).to receive(:call).with(openai_api_key:).and_return(openai_api_key.present?)
  end

  context 'without a user' do
    let(:user) { nil }

    context 'when task is private' do
      let(:access_level) { :private }

      it { is_expected.to forbid_all_actions }
    end

    context 'when task is public' do
      let(:access_level) { :public }

      it { is_expected.to permit_only_actions(%i[show download]) }
    end
  end

  context 'with a user' do
    let(:user) { create(:user, openai_api_key:) }
    let(:generic_user_permissions) { %i[index new import_start import_confirm import_uuid_check import_external] }

    it { is_expected.to permit_only_actions(generic_user_permissions) }

    context 'when user is admin' do
      let(:user) { create(:admin, openai_api_key:) }

      context 'without gpt access token' do
        let(:openai_api_key) { nil }

        it { is_expected.to forbid_only_actions %i[generate_test contribute] }
        it { is_expected.to permit_actions(generic_user_permissions) }
      end

      context 'with gpt access token' do
        let(:openai_api_key) { 'access_token' }

        it { is_expected.to forbid_only_actions %i[generate_test contribute] }
      end
    end

    context 'when task is from user' do
      let(:task_user) { user }

      context 'without gpt access token' do
        let(:openai_api_key) { nil }

        it { is_expected.to forbid_only_actions %i[generate_test contribute] }
        it { is_expected.to permit_actions(generic_user_permissions + %i[edit update show export_external_start export_external_check export_external_confirm download add_to_collection duplicate]) }
      end

      context 'with gpt access token' do
        let(:openai_api_key) { 'access_token' }

        it { is_expected.to forbid_only_actions %i[contribute] }
      end
    end

    context 'when task has access_level "public"' do
      let(:task_user) { create(:user) }
      let(:access_level) { :public }

      it { is_expected.to permit_only_actions(generic_user_permissions + %i[show export_external_start export_external_check export_external_confirm download add_to_collection duplicate contribute]) }
    end

    context 'when task is "private" and in same group' do
      let(:access_level) { :private }
      let(:user) { create(:user, openai_api_key:) }

      let(:role) { :confirmed_member }
      let(:group_memberships) { [build(:group_membership, :with_admin), build(:group_membership, user:, role:)] }
      let(:groups) { create_list(:group, 1, group_memberships:) }

      let(:group_member_permissions) { generic_user_permissions + %i[edit update duplicate show export_external_start export_external_check export_external_confirm download add_to_collection duplicate] }

      context 'when user is group-admin' do
        let(:role) { :admin }

        context 'without gpt access token' do
          let(:openai_api_key) { nil }

          it { is_expected.to forbid_actions(%i[generate_test]) }
          it { is_expected.to permit_actions(group_member_permissions) }
        end
      end
    end
  end
end
