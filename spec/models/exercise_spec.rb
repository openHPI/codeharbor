# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe Exercise, type: :model do
  describe '#add_attributes' do
    let(:exercise) { create(:only_meta_data) }
    let(:file_type) { create(:file_type) }
    let(:tests) { Test.where(exercise_id: exercise.id) }
    let(:files) { ExerciseFile.where(exercise_id: exercise.id) }
    let(:descriptions) { Description.where(exercise_id: exercise.id) }

    context 'when params attributes are nil' do
      subject(:add_empty_attributes) do
        exercise.add_attributes(params)
        exercise.save
      end

      let(:params) { {tests_attributes: nil, exercise_files_attributes: nil, descriptions_attributes: nil} }

      it { expect { add_empty_attributes }.not_to(change(tests, :size)) }
      it { expect { add_empty_attributes }.not_to(change(files, :size)) }
      it { expect { add_empty_attributes }.not_to(change(descriptions, :size)) }
    end

    context 'when params attributes are set' do
      subject(:add_attributes) do
        exercise.add_attributes(params)
        exercise.save!
      end

      let(:params) do
        ActionController::Parameters.new(
          tests_attributes: {
            '0' => {
              exercise_file_attributes: {
                name: 'test',
                file_type_id: file_type.id,
                content: 'this is some test',
                hidden: 'false',
                read_only: 'true'
              },
              feedback_message: 'not_working',
              _destroy: false,
              testing_framework: {name: 'pytest', id: '12345678'}
            }
          },
          exercise_files_attributes: {
            '0' => {
              role: 'Main File',
              content: 'some new exercise',
              path: 'some/path/',
              purpose: 'a new purpose',
              name: 'awesome',
              file_type_id: file_type.id,
              hidden: 'false',
              read_only: 'false',
              _destroy: false
            }
          },
          descriptions_attributes: {
            '0' => {
              text: 'a new description', language: 'de', _destroy: false
            }
          }
        )
      end

      it 'creates a test' do
        expect { add_attributes }.to change(tests, :size).by(1)
      end

      it 'creates files' do
        expect { add_attributes }.to change(files, :size).by(2) # Actual file and test.exercise_file
      end

      it 'creates an exercise_file' do
        add_attributes
        expect(tests[0].exercise_file).to be_truthy
      end

      it 'creates a description' do
        expect { add_attributes }.to change(descriptions, :size).by(1)
      end
    end
  end

  describe '.search' do
    subject { Exercise.search(search, settings, option, user_param) }

    let(:search) {}
    let(:settings) do
      {stars: stars, created: created, language: language, proglanguage: proglanguage}
    end
    let(:option) { 'mine' }
    let(:user_param) { user }

    let(:user) { create(:user) }
    let(:stars) {}
    let(:created) {}
    let(:language) {}
    let(:proglanguage) { [] }

    it { is_expected.to be_empty }

    context 'when exercise exists' do
      before { exercise }

      let(:exercise) { create(:simple_exercise) }

      it { is_expected.to be_empty }

      context 'when exercise belongs to user' do
        let(:exercise) { create(:simple_exercise, user: user) }

        it { is_expected.to include exercise }
      end

      context 'when option is private' do
        let(:option) { 'private' }

        it { is_expected.to be_empty }

        context 'when exercise is private' do
          let(:exercise) { create(:simple_exercise, private: true) }

          it { is_expected.to include exercise }
        end
      end

      context 'when option is public' do
        let(:option) { 'public' }

        it { is_expected.to be_empty }

        context 'when exercise is explicitly public' do
          let(:exercise) { create(:simple_exercise, private: false) }

          it { is_expected.to include exercise }
        end
      end
    end

    context 'when user has multiple exercises' do
      before do
        exercise_list
        exercise
      end

      let(:exercise_list) { create_list(:simple_exercise, 3, user: user) }
      let(:exercise) { create(:simple_exercise, user: user, title: 'filter me') }

      it { is_expected.to match_array [*exercise_list, exercise] }

      context 'when search is set' do
        let(:search) { 'nomatch' }

        it { is_expected.to be_empty }
      end

      context 'when title is searched' do
        let(:search) { 'filter' }

        it { is_expected.to include exercise }
      end

      context 'when label is search' do
        let(:exercise) { create(:simple_exercise, user: user, labels: [create(:label, name: 'filterlabel')]) }
        let(:search) { 'filterlabel' }

        it { is_expected.to include exercise }
      end

      context 'when description is searched' do
        let(:exercise) { create(:simple_exercise, user: user, descriptions: [create(:simple_description, text: 'filtertext')]) }
        let(:search) { 'filtertext' }

        it { is_expected.to include exercise }
      end
    end
  end

  describe '#destroy' do
    let(:user) { create(:user) }
    let!(:exercise) { create(:simple_exercise, user: user) }

    it 'deletes exercise' do
      expect { exercise.destroy }.to change(Exercise, :count).by(-1)
    end

    context 'when exercise is in a collection' do
      let!(:collection) { create(:collection, users: [user], exercises: [exercise]) }

      it 'gets removed from collection' do
        expect { exercise.destroy }.to change(collection.exercises, :count).by(-1)
      end
    end

    context 'when exercise is in a cart' do
      let!(:cart) { create(:cart, user: user, exercises: [exercise]) }

      it 'gets removed from cart' do
        expect { exercise.destroy }.to change(cart.exercises, :count).by(-1)
      end
    end
  end

  describe 'custom matcher' do
    let(:exercise1) { build(:exercise) }
    let(:exercise2) { build(:exercise) }

    before do
      FactoryBot.rewind_sequences
      exercise1
      FactoryBot.rewind_sequences
      exercise2
    end

    it 'matches the exercises' do
      expect(exercise1).to be_an_equal_exercise_as exercise2
    end

    context 'when titles are different' do
      let(:exercise2) { build(:exercise, title: 'title2') }

      it 'does not match the exercises' do
        expect(exercise1).not_to be_an_equal_exercise_as exercise2
      end
    end

    context 'when exercise has descriptions' do
      let(:exercise1) { build(:exercise, descriptions: [build(:description, text: 'text')]) }
      let(:exercise2) { build(:exercise, descriptions: [build(:description, text: 'text')]) }

      it 'matches the exercises' do
        expect(exercise1).to be_an_equal_exercise_as exercise2
      end

      context 'when descriptions are different' do
        let(:exercise2) { build(:exercise, descriptions: [build(:description, text: 'text2')]) }

        it 'does not match the exercises' do
          expect(exercise1).not_to be_an_equal_exercise_as exercise2
        end
      end
    end

    context 'when exercise has tests' do
      let(:exercise1) { build(:exercise, tests: [build(:test, feedback_message: 'feedback_message')]) }
      let(:exercise2) { build(:exercise, tests: [build(:test, feedback_message: 'feedback_message')]) }

      it 'matches the exercises' do
        expect(exercise1).to be_an_equal_exercise_as exercise2
      end

      context 'when descriptions are different' do
        let(:exercise2) { build(:exercise, tests: [build(:test, feedback_message: 'feedback_message2')]) }

        it 'does not match the exercises' do
          expect(exercise1).not_to be_an_equal_exercise_as exercise2
        end
      end
    end

    context 'when exercise has tests' do
      let(:exercise1) { build(:exercise, exercise_files: [build(:exercise_file, purpose: 'purpose')]) }
      let(:exercise2) { build(:exercise, exercise_files: [build(:exercise_file, purpose: 'purpose')]) }

      it 'matches the exercises' do
        expect(exercise1).to be_an_equal_exercise_as exercise2
      end

      context 'when descriptions are different' do
        let(:exercise2) { build(:exercise, exercise_files: [build(:exercise_file, purpose: 'purpose2')]) }

        it 'does not match the exercises' do
          expect(exercise1).not_to be_an_equal_exercise_as exercise2
        end
      end
    end
  end
end
