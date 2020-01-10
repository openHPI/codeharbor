# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe User, type: :model do
  fdescribe 'abilities' do
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
    it { is_expected.not_to be_able_to(:soft_delete, user) }
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
      it { is_expected.not_to be_able_to(:soft_delete, user) }
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
        it { is_expected.to be_able_to(:soft_delete, user) }
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
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
  end

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
    let!(:exercise) { FactoryBot.create(:exercise, authors: [user1]) }

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

    context 'when user is in a user' do
      before { user }

      let(:user) { create(:user, users: [user]) }

      it { is_expected.to be true }

      it 'deletes user' do
        expect { soft_delete }.to change(user, :count).by(-1)
      end

      context 'when another user is in the user' do
        before { user.users << other_user }

        let(:other_user) { create(:user) }

        it { is_expected.to be true }

        it 'does not delete user' do
          expect { soft_delete }.not_to change(user, :count)
        end

        context 'when user is admin of user' do
          before { user.make_admin user }

          it { is_expected.to be false }

          it 'does not delete user' do
            expect { soft_delete }.not_to change(user, :count)
          end
        end

        context 'when both users are admins of user' do
          before do
            user.make_admin user
            user.make_admin other_user
          end

          it { is_expected.to be true }

          it 'does not delete user' do
            expect { soft_delete }.not_to change(user, :count)
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
          create(:message, sender: user, param_type: 'user')
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

  describe 'users_sorted_by_admin_state_and_name' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:user1) { FactoryBot.create(:user, users: [user], name: 'C') }
    let!(:user2) { FactoryBot.create(:user, users: [user], name: 'B') }
    let!(:user3) { FactoryBot.create(:user, users: [user], name: 'D') }
    let!(:user4) { FactoryBot.create(:user, users: [user], name: 'A') }

    before do
      # Useruser.set_is_admin(user1.id, user.id, true)
      # Useruser.set_is_admin(user2.id, user.id, true)
      user1.make_admin(user)
      user2.make_admin(user)
    end

    it 'returns all users' do
      expect(user.users_sorted_by_admin_state_and_name).to match_array([user1, user2, user3, user4])
    end

    it 'returns the users where the user is admin sorted by name and following by a sorted list of users where the user is no admin' do
      expect(user.users_sorted_by_admin_state_and_name).to match([user2, user1, user4, user3])
    end
  end

  describe 'exercise visible for user' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:user2) { FactoryBot.create(:user) }
    let!(:user) { FactoryBot.create(:user, users: [user]) }
    let!(:exercise) { FactoryBot.create(:only_meta_data, :with_primary_description, private: false, authors: [user]) }
    let!(:exercise2) { FactoryBot.create(:only_meta_data, :with_primary_description, private: true, authors: [user]) }
    let!(:exercise3) { FactoryBot.create(:only_meta_data, :with_primary_description, private: true, authors: [user2], users: [user]) }

    it 'allows access to a public exercise to all users' do
      expect(exercise.can_access(user2)).to be true
    end

    it 'does not allow access for any user to a private exercise' do
      expect(exercise2.can_access(user2)).to be false
    end

    it 'allows access to a private exercise to the the author of the exercise' do
      expect(exercise2.can_access(user)).to be true
    end

    it 'allows access to a private exercise to the member of a user which was granted access' do
      expect(exercise3.can_access(user)).to be true
    end
  end
end
