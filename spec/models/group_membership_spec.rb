# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupMembership, type: :model do
  describe 'validations' do
    let(:group) { create(:group) }
    let(:member) { create(:user) }
    let(:membership_type) { 'member' }
    let(:group_membership) { build(:group_membership, member: member, group: group, membership_type: membership_type) }

    it 'is valid' do
      expect(group_membership).to be_valid
    end

    context 'when a group_membership with the same values already exists' do
      before { create(:group_membership, member: member, group: group, membership_type: membership_type) }

      it 'is not valid' do
        expect(group_membership).not_to be_valid
      end

      context 'when member is different' do
        let(:group) { create(:group) }

        let(:member) { create(:user) }

        let(:membership_type) { 'member' }

      end
    end

    # context 'when user get removed from group' do
    #   it 'has correct error' do
    #     group.validate
    #     expect(group.errors.full_messages).to include I18n.t('groups.no_admin_validation')
    #   end
    # end
  end
end
