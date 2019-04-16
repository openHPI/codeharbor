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
      expect(user.cart_count).to be_eql(0)
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

  describe 'handles Groups when destroyed' do
    let!(:user) { FactoryBot.create(:user) }
    let(:second_user) { FactoryBot.create(:user) }
    let(:third_user) { FactoryBot.create(:user) }
    let(:one_member_group) { FactoryBot.create(:group, users: [user]) }
    let(:many_members_group) { FactoryBot.create(:group, users: [user, second_user, third_user]) }

    it 'deletes a user' do
      user_count = described_class.count
      expect(user.soft_delete).to be_truthy
      expect(described_class.count).to eql(user_count - 1)
    end

    it 'deletes the user and group when user is last member' do
      # UserGroup.set_is_admin(one_member_group.id, user.id, true)
      one_member_group.make_admin(user)
      group_count = Group.all.count
      expect(user.soft_delete).to be_truthy
      expect(Group.all.count).to eql(group_count - 1)
    end

    it 'deletes the user when user is one of many admins' do
      # UserGroup.set_is_admin(many_members_group.id, user.id, true)
      # UserGroup.set_is_admin(many_members_group.id, second_user.id, true)
      # UserGroup.set_is_active(many_members_group.id, user.id, true)
      # UserGroup.set_is_active(many_members_group.id, second_user.id, true)

      many_members_group.make_admin(user)
      many_members_group.make_admin(second_user)

      group_count = Group.all.count
      # require 'pry'
      # binding.pry
      # user.destroy
      expect(user.soft_delete).to be_truthy
      expect(Group.all.count).to eql(group_count)
    end

    it 'does not delete the user when user is last admin and there are other members in group ' do
      # UserGroup.set_is_admin(many_members_group.id, user.id, true)
      # UserGroup.set_is_active(many_members_group.id, user.id, true)
      # UserGroup.set_is_active(many_members_group.id, second_user.id, true)
      # UserGroup.set_is_active(many_members_group.id, third_user.id, true)

      many_members_group.make_admin(user)
      many_members_group.grant_access(second_user)
      many_members_group.grant_access(third_user)

      group_count = Group.all.count
      user_count = described_class.count
      expect(user.soft_delete).to be_falsey
      expect(described_class.count).to eql(user_count)
      expect(Group.all.count).to eql(group_count)
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

    it 'allows to users to be created without a primary email' do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      expect(user1).to be_valid
      expect(user2).to be_valid
      expect(user1.email).not_to eql user2.email
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
