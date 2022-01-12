# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe User, type: :model do
  describe 'abilities' do
    subject(:ability) { Ability.new(current_user) }

    let(:current_user) { nil }
    let(:user) { create(:user) }
    let(:role) { 'member' }

    it { is_expected.not_to be_able_to(:index, described_class) }
    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:new, described_class) }
    it { is_expected.not_to be_able_to(:manage, described_class) }

    it { is_expected.not_to be_able_to(:show, user) }
    it { is_expected.not_to be_able_to(:view, user) }
    it { is_expected.not_to be_able_to(:message, user) }
    it { is_expected.not_to be_able_to(:edit, user) }
    it { is_expected.not_to be_able_to(:update, user) }
    it { is_expected.not_to be_able_to(:destroy, user) }
    it { is_expected.not_to be_able_to(:delete, user) }
    it { is_expected.not_to be_able_to(:manage_accountlinks, user) }
    it { is_expected.not_to be_able_to(:remove_account_link, user) }

    context 'with a current_user' do
      let(:current_user) { create(:user) }

      it { is_expected.not_to be_able_to(:index, described_class) }
      it { is_expected.not_to be_able_to(:create, described_class) }
      it { is_expected.not_to be_able_to(:new, described_class) }
      it { is_expected.not_to be_able_to(:manage, described_class) }

      it { is_expected.to be_able_to(:show, user) }
      it { is_expected.to be_able_to(:view, user) }
      it { is_expected.to be_able_to(:message, user) }
      it { is_expected.not_to be_able_to(:edit, user) }
      it { is_expected.not_to be_able_to(:update, user) }
      it { is_expected.not_to be_able_to(:destroy, user) }
      it { is_expected.not_to be_able_to(:delete, user) }
      it { is_expected.not_to be_able_to(:manage_accountlinks, user) }
      it { is_expected.not_to be_able_to(:remove_account_link, user) }

      context 'when current_user is admin' do
        let(:current_user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, user) }
      end

      context 'when current_user is user' do
        let(:user) { current_user }

        it { is_expected.not_to be_able_to(:index, described_class) }
        it { is_expected.not_to be_able_to(:create, described_class) }
        it { is_expected.not_to be_able_to(:new, described_class) }
        it { is_expected.not_to be_able_to(:manage, described_class) }

        it { is_expected.to be_able_to(:show, user) }
        it { is_expected.to be_able_to(:view, user) }
        it { is_expected.not_to be_able_to(:message, user) }
        it { is_expected.to be_able_to(:edit, user) }
        it { is_expected.to be_able_to(:update, user) }
        it { is_expected.to be_able_to(:delete, user) }
        it { is_expected.to be_able_to(:manage_accountlinks, user) }
        it { is_expected.to be_able_to(:remove_account_link, user) }
      end
    end
  end

  describe '#valid?' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end

  describe '#destroy' do
    subject(:destroy) { user.destroy }

    let!(:user) { create(:user) }

    it 'hashes email' do
      expect { destroy }.to change(user, :email).to Digest::MD5.hexdigest(user.email)
    end

    it { is_expected.to be true }

    it 'changes first_name to deleted' do
      expect { destroy }.to change(user, :first_name).to 'deleted'
    end

    it 'changes last_name to user' do
      expect { destroy }.to change(user, :last_name).to 'user'
    end

    it 'changes deleted to deleted' do
      expect { destroy }.to change(user, :deleted).to true
    end

    context 'when user is in a group' do
      before { group }

      let(:group) { create(:group, users: [create(:user), user]) }

      it { is_expected.to be true }

      it 'does not delete group' do
        expect { destroy }.not_to change(Group, :count)
      end

      context 'when user is admin and only user in group' do
        let(:group) { create(:group, users: [user]) }

        it 'deletes group' do
          expect { destroy }.to change(Group, :count).by(-1)
        end
      end

      context 'when another user is in the group' do
        before { group.users << other_user }

        let(:other_user) { create(:user) }

        it { is_expected.to be true }

        it 'does not delete group' do
          expect { destroy }.not_to change(Group, :count)
        end

        context 'when user is the only admin of group' do
          let(:group) { create(:group, users: [user, create(:user)]) }

          it { is_expected.to be false }

          it 'does not delete group' do
            expect { destroy }.not_to change(Group, :count)
          end
        end

        context 'when both users are admins of group' do
          before do
            group.make_admin user
            group.make_admin other_user
          end

          it { is_expected.to be true }

          it 'does not delete group' do
            expect { destroy }.not_to change(Group, :count)
          end
        end
      end
    end

    context 'when user has a collection' do
      before { create(:collection, users: users) }

      let(:users) { [user] }

      it 'deletes collection' do
        expect { destroy }.to change(Collection, :count).by(-1)
      end

      context 'when another user also has that collection' do
        let(:users) { [user, create(:user)] }

        it 'deletes collection' do
          expect { destroy }.not_to change(Collection, :count)
        end
      end
    end

    xcontext 'when user has an exercise' do
      before { user.exercises << exercise }

      let(:exercise) { create(:simple_exercise, user: user) }

      it 'changes user of exercise to nil' do
        expect { destroy }.to change { exercise.reload.user }.from(user).to(nil)
      end
    end

    context 'when user has sent messages' do
      before { create(:message, sender: user) }

      it 'does not delete message' do
        expect { destroy }.not_to change(Message, :count)
      end

      xcontext 'when message has type exercise' do
        before do
          create(:message, sender: user, param_type: 'exercise')
          create(:message, sender: user, param_type: 'group')
          create(:message, sender: user, param_type: 'collection')
        end

        it 'deletes message' do
          expect { destroy }.to change(Message, :count).by(-3)
        end
      end
    end
  end

  describe 'factories' do
    it 'has valid factory' do
      expect(build_stubbed(:user)).to be_valid
    end

    it 'requires first name' do
      expect(build_stubbed(:user, first_name: '')).not_to be_valid
    end

    it 'requires last name' do
      expect(build_stubbed(:user, last_name: '')).not_to be_valid
    end

    it 'requires email' do
      expect(build_stubbed(:user, email: '')).not_to be_valid
    end

    it 'uses the provided primary email for created users' do
      email = 'test@example.com'
      user = create(:user, email: 'test@example.com')
      user.email = email
    end

    it 'uses the provided primary email even for stubbed users' do
      email = 'test@example.com'
      user = build_stubbed(:user, email: 'test@example.com')
      user.email = email
    end

    context 'when two users are created' do
      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }

      it 'creates valid user1' do
        expect(user1).to be_valid
      end

      it 'creates valid user2' do
        expect(user2).to be_valid
      end

      it 'allows two users to be created without a primary email' do
        expect(user1.email).not_to eql user2.email
      end
    end
  end

  xdescribe 'exercise visible for user' do
    let!(:user) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:group) { create(:group, users: [user]) }
    let!(:exercise) { create(:only_meta_data, :with_primary_description, private: false, authors: [user]) }
    let!(:exercise2) { create(:only_meta_data, :with_primary_description, private: true, authors: [user]) }
    let!(:exercise3) { create(:only_meta_data, :with_primary_description, private: true, authors: [user2], groups: [group]) }

    it 'allows access to a public exercise to all users' do
      expect(exercise.can_access(user2)).to be true
    end

    it 'does not allow access for any user to a private exercise' do
      expect(exercise2.can_access(user2)).to be false
    end

    it 'allows access to a private exercise to the the author of the exercise' do
      expect(exercise2.can_access(user)).to be true
    end

    it 'allows access to a private exercise to the member of a group which was granted access' do
      expect(exercise3.can_access(user)).to be true
    end
  end

  describe '#available_account_links' do
    subject(:available_account_links) { user.available_account_links }

    let(:user) { create(:user) }

    it { is_expected.to be_empty }

    context 'when an account_link exists' do
      let!(:account_link) { create(:account_link, user: another_user) }
      let(:another_user) { create(:user) }

      it { is_expected.to be_empty }

      context 'when user owns account_link' do
        let(:another_user) { user }

        it 'contains account_link' do
          expect(available_account_links).to include(account_link)
        end
      end

      context 'when account_link is shared' do
        before { create(:account_link_user, user: user, account_link: account_link) }

        it 'contains account_link' do
          expect(available_account_links).to include(account_link)
        end
      end
    end
  end
end
