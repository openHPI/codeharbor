# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Test, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:task) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:xml_id) }
    it { is_expected.to validate_uniqueness_of(:xml_id).scoped_to(:task_id) }
  end

  xdescribe '#duplicate' do
    subject(:duplicate) { test.duplicate }

    let(:test) { create(:test) }

    it 'creates a new test' do
      expect(duplicate).not_to be test
    end

    it 'has the same attributes' do
      expect(duplicate).to have_attributes(test.attributes.except('created_at', 'updated_at', 'id', 'exercise_file_id'))
    end

    it 'creates a new exercise_file' do
      expect(duplicate.exercise_file).not_to be test.exercise_file
    end

    it 'creates a new exercise_file with the same attribute' do
      expect(duplicate.exercise_file).to have_attributes(test.exercise_file.attributes.except('created_at', 'updated_at', 'id', 'test_id'))
    end
  end
end
