# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe User, type: :model do
  describe 'cart count' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:exercise1) { FactoryBot.create(:simple_exercise) }
    let!(:exercise2) { FactoryBot.create(:simple_exercise) }
    let(:cart) { FactoryBot.create(:cart, user: user, exercises: [exercise1]) }

    it 'return +1 when exercise is added' do
      count = user.cart_count
      cart.add_exercise(exercise1)
      expect(user.cart_count).to be_eql(count + 1)
    end

    it 'return -1 when exercise is removed' do
      cart.add_exercise(exercise2)
      count = user.cart_count
      cart.remove_exercise(exercise2)
      expect(user.cart_count).to be_eql(count - 1)
    end

    it 'return 0 when cart got destroyed' do
      cart.destroy
      expect(user.reload.cart_count).to be_eql(0)
    end
  end

  describe 'is_author' do
    let!(:user1) { FactoryBot.create(:user) }
    let!(:user2) { FactoryBot.create(:user) }
    let!(:exercise) { FactoryBot.create(:exercise_with_author, authors: [user1]) }

    it 'returns true for author' do
      expect(user1.author?(exercise)).to be true
    end

    it 'return false for not author' do
      expect(user2.author?(exercise)).to be false
    end
  end

  describe '#soft_delete' do
    subject(:soft_delete) { user.soft_delete }

    let!(:user) { create(:user) }

    it 'hashes email' do
      expect { soft_delete }.to change(user, :email).to Digest::MD5.hexdigest(user.email)
    end

    it { is_expected.to be true }

    it 'changes first_name to deleted' do
      expect { soft_delete }.to change(user, :first_name).to 'deleted'
    end

    it 'changes last_name to user' do
      expect { soft_delete }.to change(user, :last_name).to 'user'
    end

    it 'changes deleted to deleted' do
      expect { soft_delete }.to change(user, :deleted).to true
    end

    context 'when user is in a group' do
      before { group }

      let(:group) { create(:group, users: [user]) }

      it { is_expected.to be true }

      it 'deletes group' do
        expect { soft_delete }.to change(Group, :count).by(-1)
      end

      context 'when another user is in the group' do
        before { group.users << other_user }

        let(:other_user) { create(:user) }

        it { is_expected.to be true }

        it 'does not delete group' do
          expect { soft_delete }.not_to change(Group, :count)
        end

        context 'when user is admin of group' do
          before { group.make_admin user }

          it { is_expected.to be false }

          it 'does not delete group' do
            expect { soft_delete }.not_to change(Group, :count)
          end
        end

        context 'when both users are admins of group' do
          before do
            group.make_admin user
            group.make_admin other_user
          end

          it { is_expected.to be true }

          it 'does not delete group' do
            expect { soft_delete }.not_to change(Group, :count)
          end
        end
      end
    end

    context 'when user has a collection' do
      before { user.collections << collection }

      let(:collection) { create(:collection, users: []) }

      it 'deletes collection' do
        expect { soft_delete }.to change(Collection, :count).by(-1)
      end

      context 'when another user also has that collection' do
        before { create(:user).collections << collection }

        let(:collection) { create(:collection) }

        it 'deletes collection' do
          expect { soft_delete }.not_to change(Collection, :count)
        end
      end
    end

    context 'when user has an exercise' do
      before { user.exercises << exercise }

      let(:exercise) { create(:simple_exercise, user: user) }

      it 'changes user of exercise to nil' do
        expect { soft_delete }.to change { exercise.reload.user }.from(user).to(nil)
      end
    end

    context 'when user has sent messages' do
      before { create(:message, sender: user) }

      it 'does not delete message' do
        expect { soft_delete }.not_to change(Message, :count)
      end

      context 'when message has type exercise' do
        before do
          create(:message, sender: user, param_type: 'exercise')
          create(:message, sender: user, param_type: 'group')
          create(:message, sender: user, param_type: 'collection')
        end

        it 'deletes message' do
          expect { soft_delete }.to change(Message, :count).by(-3)
        end
      end
    end
  end

  describe '#destroy' do
    subject(:destroy) { user.destroy }

    let(:user) { create(:user) }

    context 'when user has a cart' do
      before { create(:cart, user: user) }

      it 'deletes cart' do
        expect { destroy }.to change(Cart, :count).by(-1)
      end
    end
  end

  describe 'factories' do
    it 'has valid factory' do
      expect(FactoryBot.build_stubbed(:user)).to be_valid
    end

    it 'requires first name' do
      expect(FactoryBot.build_stubbed(:user, first_name: '')).not_to be_valid
    end

    it 'requires last name' do
      expect(FactoryBot.build_stubbed(:user, last_name: '')).not_to be_valid
    end

    it 'requires email' do
      expect(FactoryBot.build_stubbed(:user, email: '')).not_to be_valid
    end

    it 'uses the provided primary email for created users' do
      email = 'test@example.com'
      user = FactoryBot.create(:user, email: 'test@example.com')
      user.email = email
    end

    it 'uses the provided primary email even for stubbed users' do
      email = 'test@example.com'
      user = FactoryBot.build_stubbed(:user, email: 'test@example.com')
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

  describe 'groups_sorted_by_admin_state_and_name' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:group1) { FactoryBot.create(:group, users: [user], name: 'C') }
    let!(:group2) { FactoryBot.create(:group, users: [user], name: 'B') }
    let!(:group3) { FactoryBot.create(:group, users: [user], name: 'D') }
    let!(:group4) { FactoryBot.create(:group, users: [user], name: 'A') }

    before do
      # UserGroup.set_is_admin(group1.id, user.id, true)
      # UserGroup.set_is_admin(group2.id, user.id, true)
      group1.make_admin(user)
      group2.make_admin(user)
    end

    it 'returns all groups' do
      expect(user.groups_sorted_by_admin_state_and_name).to match_array([group1, group2, group3, group4])
    end

    it 'returns the groups where the user is admin sorted by name and following by a sorted list of groups where the user is no admin' do
      expect(user.groups_sorted_by_admin_state_and_name).to match([group2, group1, group4, group3])
    end
  end

  describe 'exercise visible for user' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:user2) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, users: [user]) }
    let!(:exercise) { FactoryBot.create(:only_meta_data, private: false, authors: [user]) }
    let!(:exercise2) { FactoryBot.create(:only_meta_data, private: true, authors: [user]) }
    let!(:exercise3) { FactoryBot.create(:only_meta_data, private: true, authors: [user2], groups: [group]) }

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
end
