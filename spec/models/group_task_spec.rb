# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupTask do
  describe 'validations' do
    subject { build(:group_task) }

    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:task) }
    it { is_expected.to validate_uniqueness_of(:task_id).scoped_to(:group_id) }
  end
end
