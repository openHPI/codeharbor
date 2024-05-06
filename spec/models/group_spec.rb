# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe Group do
  describe 'validations' do
    let(:group_memberships) { build_list(:group_membership, 1, :with_admin) }
    let(:group) { build(:group, group_memberships:) }
    let(:user) { build(:user) }

    it 'is valid' do
      expect(group.valid?).to be true
    end

    context 'when group has no admin' do
      let(:group_memberships) { [] }

      it 'is not valid' do
        expect(group.valid?).to be false
      end

      it 'has correct error' do
        group.validate
        expect(group.errors.full_messages).to include I18n.t('activerecord.errors.models.group.attributes.base.no_admin')
      end
    end
  end

  describe '#remove_member' do
    let(:group_memberships) { [build(:group_membership, :with_admin, user: admin), build(:group_membership, user:)] }
    let(:group) { create(:group, group_memberships:) }
    let(:admin) { create(:user) }
    let(:user) { create(:user) }

    it 'deletes member' do
      expect { group.remove_member(user) }.to change(group.users, :count).by(-1)
    end

    it 'does not delete admin' do
      expect { group.remove_member(admin) }.to raise_error(ActiveRecord::RecordInvalid).and avoid_change(group.users, :count)
    end

    context 'when group has another admin' do
      let(:admin2) { create(:user) }

      before do
        group.add(admin2, role: :admin)
        group.reload
      end

      it 'allows deletion of admin' do
        expect { group.remove_member(admin) }.to change(group.users, :count).by(-1)
      end
    end
  end

  describe '#add' do
    subject(:add) { group.add(user) }

    let(:user) { build(:user) }
    let!(:group) { create(:group) }

    it 'adds user to the group' do
      expect { add }.to change(group.users, :count).by(1)
    end

    it 'adds user as confirmed_member' do
      add
      expect(group.group_membership_for(user).role).to eql 'confirmed_member'
    end

    context 'when admin is supplied as role' do
      subject(:add) { group.add(user, role: :admin) }

      it 'adds user as admin' do
        add
        expect(group.group_membership_for(user).role).to eql 'admin'
      end
    end

    context 'when applicant is supplied as role' do
      subject(:add) { group.add(user, role: :applicant) }

      it 'adds user as applicant' do
        add
        expect(group.group_membership_for(user).role).to eql 'applicant'
      end
    end

    context 'when user is already in group' do
      before { group.users << user }

      it 'does not add user' do
        expect { add }.to raise_error(ActiveRecord::RecordInvalid).and(avoid_change(group.users, :count))
      end
    end
  end

  describe '#group_membership_for' do
    subject { group.group_membership_for(user) }

    let(:user) { build(:user) }
    let!(:group) { create(:group) }

    it { is_expected.to be_nil }

    context 'when user is in group' do
      let(:group) { create(:group, group_memberships:) }
      let(:group_memberships) { [group_membership, *build_list(:group_membership, 2)] }
      let(:group_membership) { build(:group_membership, :with_admin, user:) }

      before { group }

      it { is_expected.to eql group_membership }
    end
  end

  describe '#admin?' do
    subject { group.admin?(user) }

    let(:user) { build(:user) }
    let(:group) { create(:group) }

    it { is_expected.to be false }

    context 'when user is in group' do
      let(:group) { create(:group, group_memberships:) }
      let(:group_memberships) { [build(:group_membership, user:), build(:group_membership, :with_admin)] }

      it { is_expected.to be false }

      context 'when user is admin' do
        let(:group_memberships) { build_list(:group_membership, 1, :with_admin, user:) }

        it { is_expected.to be true }
      end
    end
  end

  describe '#confirmed_member?' do
    subject { group.confirmed_member?(user) }

    let(:user) { build(:user) }
    let(:group) { create(:group) }

    it { is_expected.to be false }

    context 'when user is in group' do
      let(:group) { create(:group, group_memberships:) }
      let(:group_memberships) { [build(:group_membership, :with_applicant, user:), build(:group_membership, :with_admin)] }

      it { is_expected.to be false }

      context 'when user is confirmed_member' do
        let(:group_memberships) { [build(:group_membership, user:), build(:group_membership, :with_admin)] }

        it { is_expected.to be true }
      end
    end
  end

  describe '#user?' do
    subject { group.user?(user) }

    let(:user) { build(:user) }
    let(:group) { create(:group) }

    it { is_expected.to be false }

    context 'when user is in group' do
      let(:group) { create(:group, group_memberships:) }
      let(:group_memberships) { [build(:group_membership, :with_applicant, user:), build(:group_membership, :with_admin)] }

      it { is_expected.to be true }

      context 'when user is confirmed_member' do
        let(:group_memberships) { [build(:group_membership, user:), build(:group_membership, :with_admin)] }

        it { is_expected.to be true }
      end

      context 'when user is admin' do
        let(:group_memberships) { build_list(:group_membership, 1, :with_admin, user:) }

        it { is_expected.to be true }
      end
    end
  end

  describe '#make_admin' do
    subject(:make_admin) { group.make_admin(user) }

    before { group }

    let(:user) { build(:user) }
    let(:group) { create(:group) }

    it { is_expected.to be false }

    it 'does not add user to group' do
      expect { make_admin }.not_to change(GroupMembership, :count)
    end

    context 'when user is in group' do
      let(:group) { create(:group, group_memberships:) }
      let(:group_memberships) { [group_membership, build(:group_membership, :with_admin)] }
      let(:group_membership) { build(:group_membership, :with_applicant, user:) }

      it { is_expected.to be false }

      it 'does not change role' do
        expect { make_admin }.not_to(change { group_membership.reload.role })
      end

      context 'when user is confirmed_member' do
        let(:group_memberships) { [group_membership, build(:group_membership, :with_admin)] }
        let(:group_membership) { build(:group_membership, user:) }

        it 'changes role to admin' do
          expect { make_admin }.to change { group_membership.reload.role }.from('confirmed_member').to('admin')
        end
      end

      context 'when user is admin' do
        let(:group_memberships) { [group_membership] }
        let(:group_membership) { build(:group_membership, :with_admin, user:) }

        it { is_expected.to be false }

        it 'does not change role' do
          expect { make_admin }.not_to(change { group_membership.reload.role })
        end
      end
    end
  end

  describe '#demote_admin' do
    subject(:demote_admin) { group.demote_admin(user) }

    before { group }

    let(:user) { build(:user) }
    let(:group_memberships) { [group_membership, build(:group_membership, :with_admin)] }

    context 'when user is in group' do
      let(:group) { create(:group, group_memberships:) }
      let(:group_membership) { build(:group_membership, :with_applicant, user:) }

      it { is_expected.to be false }

      it 'does not change role' do
        expect { demote_admin }.not_to(change { group_membership.reload.role })
      end

      context 'when user is confirmed_member' do
        let(:group_membership) { build(:group_membership, user:) }

        it { is_expected.to be false }

        it 'does not change role' do
          expect { demote_admin }.not_to(change { group_membership.reload.role })
        end
      end

      context 'when user is admin' do
        let(:group_membership) { build(:group_membership, :with_admin, user:) }

        it { is_expected.to be true }

        it 'changes role to confirmed_member' do
          expect { demote_admin }.to change { group_membership.reload.role }.from('admin').to('confirmed_member')
        end
      end

      context 'when user is the only admin' do
        let(:group_memberships) { [group_membership] }
        let(:group_membership) { build(:group_membership, :with_admin, user:) }

        it { is_expected.to be false }

        it 'does not change role' do
          expect { demote_admin }.not_to change { group_membership.reload.role }
        end
      end
    end
  end

  describe '#grant_access' do
    subject(:grant_access) { group.grant_access(user) }

    before { group }

    let(:user) { build(:user) }
    let(:group) { create(:group) }

    it { is_expected.to be false }

    it 'does not add user to group' do
      expect { grant_access }.not_to change(GroupMembership, :count)
    end

    context 'when user is in group' do
      let(:group) { create(:group, group_memberships:) }
      let(:group_memberships) { [group_membership, build(:group_membership, :with_admin)] }
      let(:group_membership) { build(:group_membership, :with_applicant, user:) }

      it 'changes role to confirmed_member' do
        expect { grant_access }.to change { group_membership.reload.role }.from('applicant').to('confirmed_member')
      end

      context 'when user is confirmed_member' do
        let(:group_memberships) { [group_membership, build(:group_membership, :with_admin)] }
        let(:group_membership) { build(:group_membership, user:) }

        it 'does not change role' do
          expect { grant_access }.not_to(change { group_membership.reload.role })
        end
      end

      context 'when user is admin' do
        let(:group_memberships) { [group_membership] }
        let(:group_membership) { build(:group_membership, :with_admin, user:) }

        it { is_expected.to be false }

        it 'does not change role' do
          expect { grant_access }.not_to(change { group_membership.reload.role })
        end
      end
    end
  end

  describe '#admins' do
    subject { group.admins }

    let(:group_memberships) do
      [build(:group_membership, :with_admin, user: admin), build(:group_membership, :with_applicant, user: applicant),
       build(:group_membership, user:)]
    end
    let(:group) { create(:group, group_memberships:) }
    let(:admin) { create(:user) }
    let(:user) { create(:user) }
    let(:applicant) { create(:user) }

    it { is_expected.to match_array(admin) }
  end

  describe '#confirmed_members' do
    subject { group.confirmed_members }

    let(:group_memberships) do
      [build(:group_membership, :with_admin, user: admin), build(:group_membership, :with_applicant, user: applicant),
       build(:group_membership, user:)]
    end
    let(:group) { create(:group, group_memberships:) }
    let(:admin) { create(:user) }
    let(:user) { create(:user) }
    let(:applicant) { create(:user) }

    it { is_expected.to match_array(user) }
  end

  describe '#applicants' do
    subject { group.applicants }

    let(:group_memberships) do
      [build(:group_membership, :with_admin, user: admin), build(:group_membership, :with_applicant, user: applicant),
       build(:group_membership, user:)]
    end
    let(:group) { create(:group, group_memberships:) }
    let(:admin) { create(:user) }
    let(:user) { create(:user) }
    let(:applicant) { create(:user) }

    it { is_expected.to match_array(applicant) }
  end

  describe '#users' do
    subject { group.users }

    let(:group_memberships) do
      [build(:group_membership, :with_admin, user: admin), build(:group_membership, :with_applicant, user: applicant),
       build(:group_membership, user:)]
    end
    let(:group) { create(:group, group_memberships:) }
    let(:admin) { create(:user) }
    let(:user) { create(:user) }
    let(:applicant) { create(:user) }

    it { is_expected.to contain_exactly(admin, user, applicant) }
  end

  describe '#last_admin?' do
    subject { group.last_admin?(user) }

    let(:user) { build(:user) }
    let(:group) { create(:group) }

    it { is_expected.to be_nil }

    context 'when user is in group' do
      let(:group) { create(:group, group_memberships:) }
      let(:group_memberships) { [build(:group_membership, user:), build(:group_membership, :with_admin)] }

      it { is_expected.to be false }

      context 'when user is admin' do
        let(:group_memberships) { build_list(:group_membership, 1, :with_admin, user:) }

        it { is_expected.to be true }

        context 'when another admin exists' do
          let(:group_memberships) { [build(:group_membership, :with_admin, user:), build(:group_membership, :with_admin)] }

          it { is_expected.to be false }
        end
      end
    end
  end
end
