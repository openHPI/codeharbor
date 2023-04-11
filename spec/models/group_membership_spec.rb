# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupMembership do
  describe 'validations' do
    subject { build(:group_membership, :with_group) }

    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:group_id) }
  end
end
