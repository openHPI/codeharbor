# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExerciseFile, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:file_type) }
    it { is_expected.to validate_presence_of(:exercise) }
    it { is_expected.to validate_presence_of(:name) }

    context 'when purpose is test' do
      subject { build(:exercise_file, purpose: 'test') }

      it { is_expected.not_to validate_presence_of(:exercise) }
      it { is_expected.to belong_to(:exercise).optional }
    end
  end

  describe '#full_file_name' do
    subject(:exercise_file) { build(:exercise_file, path: path, name: name, file_type: file_type) }

    let(:path) { 'folder' }
    let(:name) { 'foo' }
    let(:file_type) { build(:file_type, file_extension: '.bar') }

    it 'returns correct pathname' do
      expect(exercise_file.full_file_name).to eql 'folder/foo.bar'
    end

    context 'without path' do
      let(:path) {}

      it 'returns correct pathname' do
        expect(exercise_file.full_file_name).to eql 'foo.bar'
      end
    end

    context 'without file_type' do
      let(:file_type) {}

      it 'returns correct pathname' do
        expect(exercise_file.full_file_name).to eql 'folder/foo'
      end
    end
  end

  describe '#full_file_name=' do
    subject(:set_full_file_name) { exercise_file.full_file_name = argument }

    let(:exercise_file) { build(:exercise_file) }
    let(:argument) { 'foo.bar' }
    let!(:file_type) { create(:file_type, file_extension: '.bar') }

    it 'sets the correct path' do
      set_full_file_name
      expect(exercise_file.path).to eql ''
    end

    it 'sets the correct name' do
      set_full_file_name
      expect(exercise_file.name).to eql 'foo'
    end

    it 'sets the correct file_type' do
      set_full_file_name
      expect(exercise_file.file_type).to eql file_type
    end

    context 'with a path in the argument' do
      let(:argument) { 'folder/foo.bar' }

      it 'sets the correct path' do
        set_full_file_name
        expect(exercise_file.path).to eql 'folder'
      end

      context 'when path is "."' do
        let(:argument) { './foo.bar' }

        it 'sets the correct path' do
          set_full_file_name
          expect(exercise_file.path).to eql ''
        end
      end
    end

    context 'with an unknown file_type' do
      let(:argument) { 'foo.baz' }

      it 'sets the correct path' do
        set_full_file_name
        expect(exercise_file.path).to eql ''
      end

      it 'creates missing unknown file_type' do
        expect { set_full_file_name }.to change(FileType, :count).by(1)
      end
    end
  end

  describe 'parse_text_data' do
    subject(:exercise_file) { build(:exercise_file, attachment: "data:text/plain;base64,#{Base64.encode64('lorem ipsum')}", content: '') }

    it 'sets content' do
      expect { exercise_file.save }.to change(exercise_file, :content).from('').to 'lorem ipsum'
    end
  end

  describe '#attached_image?' do
    subject { exercise_file.attached_image? }

    let(:exercise_file) { build(:exercise_file, attachment: nil) }

    it { is_expected.to be false }

    context 'with image attachment' do
      let(:exercise_file) { build(:codeharbor_regular_file, :with_attachment) }

      it { is_expected.to be true }
    end

    context 'with text attachment' do
      let(:exercise_file) { build(:exercise_file, attachment: "data:text/plain;base64,#{Base64.encode64('lorem ipsum')}") }

      it { is_expected.to be false }
    end
  end

  describe '#duplicate' do
    subject(:duplicate) { exercise_file.duplicate }

    let(:exercise_file) { create(:exercise_file) }

    it 'creates a new exercise_file object' do
      expect(duplicate).not_to eql exercise_file
    end

    it 'has same attributes' do
      expect(duplicate).to have_attributes(exercise_file.attributes.with_indifferent_access.except(:id, :created_at, :updated_at))
    end

    context 'with an exercise' do
      subject(:duplicate) { exercise_file.duplicate(exercise: exercise) }

      let(:exercise) { create(:exercise) }

      it 'has same attributes' do
        expect(duplicate)
          .to have_attributes(exercise_file.attributes.with_indifferent_access.except(:id, :created_at, :updated_at, :exercise_id))
      end

      it 'sets exercise correctly' do
        expect(duplicate.exercise).to eql exercise
      end
    end
  end
end
