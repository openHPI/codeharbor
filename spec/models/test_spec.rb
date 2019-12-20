# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Test, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:exercise) }
    it { is_expected.to belong_to(:exercise_file) }
    it { is_expected.to belong_to(:testing_framework).optional }
  end

  describe '#content' do
    subject { test.content }

    let(:test) { build(:test, exercise_file: nil) }

    it { is_expected.to be '' }

    context 'when test has a file' do
      let(:test) { build(:test, exercise_file: exercise_file) }
      let(:exercise_file) { build(:exercise_file) }

      it { is_expected.to be exercise_file.content }
    end
  end

  describe '#name' do
    subject { test.name }

    let(:test) { build(:test, exercise_file: nil) }

    it { is_expected.to be '' }

    context 'when test has a file' do
      let(:test) { build(:test, exercise_file: exercise_file) }
      let(:exercise_file) { build(:exercise_file) }

      it { is_expected.to be exercise_file.name }
    end
  end

  describe '#path' do
    subject { test.path }

    let(:test) { build(:test, exercise_file: nil) }

    it { is_expected.to be '' }

    context 'when test has a file' do
      let(:test) { build(:test, exercise_file: exercise_file) }
      let(:exercise_file) { build(:exercise_file) }

      it { is_expected.to be exercise_file.path }
    end
  end

  describe '#file_type_id' do
    subject { test.file_type_id }

    let(:test) { build(:test, exercise_file: nil) }

    it { is_expected.to be '' }

    context 'when test has a file' do
      let(:test) { create(:test, exercise_file: exercise_file) }
      let(:exercise_file) { build(:exercise_file) }

      it { is_expected.to be exercise_file.file_type_id }
    end
  end

  describe '#file_type' do
    subject { test.file_type }

    let(:test) { build(:test, exercise_file: nil) }

    it { is_expected.to be nil }

    context 'when test has a file' do
      let(:test) { build(:test, exercise_file: exercise_file) }
      let(:exercise_file) { build(:exercise_file) }

      it { is_expected.to be exercise_file.file_type }
    end
  end

  describe '#full_file_name' do
    subject { test.full_file_name }

    let(:test) { build(:test, exercise_file: nil) }

    it { is_expected.to be nil }

    context 'when test has a file' do
      let(:test) { build(:test, exercise_file: exercise_file) }
      let(:exercise_file) { build(:exercise_file) }

      it { is_expected.to eql exercise_file.full_file_name }
    end
  end

  describe '#attachment' do
    subject { test.attachment }

    let(:test) { build(:test, exercise_file: nil) }

    it { is_expected.to be nil }

    context 'when test has a file' do
      let(:test) { build(:test, exercise_file: exercise_file) }
      let(:exercise_file) { build(:codeharbor_regular_file, :with_attachment) }

      it { is_expected.to be exercise_file.attachment }
    end
  end

  describe '#attached_image?' do
    subject { test.attached_image? }

    let(:test) { build(:test, exercise_file: nil) }

    it { is_expected.to be false }

    context 'when test has a file' do
      let(:test) { create(:test, exercise_file: exercise_file) }

      context 'when file is an image' do
        let(:exercise_file) { build(:codeharbor_regular_file, :with_image_attachment) }

        it { is_expected.to be true }
      end

      context 'when file is a text file' do
        let(:exercise_file) { build(:codeharbor_regular_file, :with_text_attachment) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#duplicate' do
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
      expect(duplicate.exercise_file).to have_attributes(test.exercise_file.attributes.except('created_at', 'updated_at', 'id'))
    end
  end
end
