# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelSolution, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:task) }
    it { is_expected.to validate_presence_of(:xml_id) }
    it { is_expected.to validate_uniqueness_of(:xml_id).scoped_to(:task_id) }
  end
end
