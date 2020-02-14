# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupMembership, type: :model do
  describe 'validations' do
    let(:group) { create(:group) }
    let(:member) { create(:user) }
    let(:type) { 'member' }
    let(:group_membership) { build(:group_membership, member: member, group: group, membership_type: type) }

    it 'is valid' do
      expect(group_membership).to be_valid
    end

    context 'when a group_membership with the same values already exists' do
      let(:group_copy) { group }
      let(:member_copy) { member }
      let(:type_copy) { type }

      before { create(:group_membership, member: member_copy, group: group_copy, membership_type: type_copy) }

      it 'is not valid' do
        expect(group_membership).not_to be_valid
      end

      context 'when member of copy is different' do
        let(:member_copy) { create(:user) }

        it 'is valid' do
          expect(group_membership).to be_valid
        end
      end

      context 'when group of copy is different' do
        let(:group_copy) { create(:group) }

        it 'is valid' do
          expect(group_membership).to be_valid
        end
      end

      context 'when membership_type of copy is different' do
        let(:type_copy) { 'admin' }

        it 'is not valid' do
          expect(group_membership).not_to be_valid
        end
      end

      context 'when membership_type of copy is nil' do
        let(:type_copy) { nil }

        it 'is valid' do
          expect(group_membership).to be_valid
        end
      end

      context 'when membership_type is nil' do
        let(:type) { nil }

        context 'when membership_type of copy is nil' do
          let(:type_copy) { nil }

          it 'is not valid' do
            expect(group_membership).not_to be_valid
          end
        end

        context 'when membership_type of copy is set' do
          let(:type_copy) { 'member' }

          it 'is valid' do
            expect(group_membership).to be_valid
          end
        end
      end
    end
  end
end
