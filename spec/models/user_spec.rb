require 'rails_helper'
require 'nokogiri'

RSpec.describe User, type: :model do
  describe 'handles Groups when destroyed' do
    let!(:user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:third_user) { FactoryGirl.create(:user) }
    let(:one_member_group) { FactoryGirl.create(:group, users: [user]) }
    let(:many_members_group) { FactoryGirl.create(:group, users: [user, second_user, third_user]) }
    
    it 'deletes a user' do
      user_count = described_class.count
      expect(user.destroy).to be_truthy
      expect(described_class.count).to eql(user_count - 1)
    end
    
    it 'deletes the user and group when user is last member' do
      UserGroup.set_is_admin(one_member_group.id, user.id, true)
      group_count = Group.all.count
      expect(user.destroy).to be_truthy
      expect(Group.all.count).to eql(group_count - 1)
    end
    
    it 'deletes the user when user is one of many admins' do
      UserGroup.set_is_admin(many_members_group.id, user.id, true)
      UserGroup.set_is_admin(many_members_group.id, second_user.id, true)
      group_count = Group.all.count
      expect(user.destroy).to be_truthy
      expect(Group.all.count).to eql(group_count)
    end
    
    it 'does not delete the user when user is last admin and there are other members in group ' do
      UserGroup.set_is_admin(many_members_group.id, user.id, true)
      group_count = Group.all.count
      user_count = described_class.count
      expect(user.destroy).to be_falsey
      expect(described_class.count).to eql(user_count)
      expect(Group.all.count).to eql(group_count)
    end
  end
  
  describe 'factories' do
    it 'has valid factory' do
      expect(FactoryGirl.build_stubbed(:user)).to be_valid
    end

    it 'requires first name' do
      expect(FactoryGirl.build_stubbed(:user, first_name: '')).not_to be_valid
    end

    it 'requires last name' do
      expect(FactoryGirl.build_stubbed(:user, last_name: '')).not_to be_valid
    end

    it 'requires email' do
      expect(FactoryGirl.build_stubbed(:user, email: '')).not_to be_valid
    end

    it 'uses the provided primary email for created users' do
      email = 'test@example.com'
      user = FactoryGirl.create(:user, email: 'test@example.com')
      user.email = email
    end

    it 'uses the provided primary email even for stubbed users' do
      email = 'test@example.com'
      user = FactoryGirl.build_stubbed(:user, email: 'test@example.com')
      user.email = email
    end

    it 'allows to users to be created without a primary email' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      expect(user1).to be_valid
      expect(user2).to be_valid
      expect(user1.email).not_to eql user2.email
    end
  end
  
  describe 'groups_sorted_by_admin_state_and_name' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:group1) { FactoryGirl.create(:group, users: [user], name: 'C') }
    let!(:group2) { FactoryGirl.create(:group, users: [user], name: 'B') }
    let!(:group3) { FactoryGirl.create(:group, users: [user], name: 'D') }
    let!(:group4) { FactoryGirl.create(:group, users: [user], name: 'A') }

    before(:each) do
      UserGroup.set_is_admin(group1.id, user.id, true)
      UserGroup.set_is_admin(group2.id, user.id, true)
    end

    it 'returns all groups' do
      expect(user.groups_sorted_by_admin_state_and_name).to match_array([group1, group2, group3, group4])
    end

    it 'returns the groups where the user is admin sorted by name and following by a sorted list of groups where the user is no admin' do
      expect(user.groups_sorted_by_admin_state_and_name).to match([group2, group1, group4, group3])
    end
  end
  
  describe 'exercise visible for user' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user2) { FactoryGirl.create(:user) }
    let!(:group) { FactoryGirl.create(:group, users: [user]) }
    let!(:exercise) {FactoryGirl.create(:only_meta_data, private: false, authors: [user])}
    let!(:exercise2) {FactoryGirl.create(:only_meta_data, private: true, authors: [user])}
    let!(:exercise3) {FactoryGirl.create(:only_meta_data, private: true, authors: [user2], access: [group])}
    
    it 'allows access to a public exercise to all users' do
      expect(exercise.can_access(user2)).to eql true
    end
    
    it 'does not allow access for any user to a private exercise' do
      expect(exercise2.can_access(user2)).to eql false
    end
    
    it 'allows access to a private exercise to the the author of the exercise' do
      expect(exercise2.can_access(user)).to eql true
    end
    
    it 'allows access to a private exercise to the member of a group which was granted access' do
      expect(exercise3.can_access(user)).to eql true
    end
  end
end