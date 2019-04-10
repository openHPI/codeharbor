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
        exercise.save
      end

      let(:params) do
        ActionController::Parameters.new(
          tests_attributes: {
            '0' => {
              exercise_file_attributes: {
                name: 'test', file_type_id: file_type.id, content: 'this is some test'
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
    let(:option) {}
    let(:user_param) { user }

    let(:user) { create(:user) }
    let(:stars) {}
    let(:created) {}
    let(:language) {}
    let(:proglanguage) { [] }

    # let(:execution_environment) { create(:java_8_execution_environment) }

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

    # context 'when user has multiple exercises' do
    #   before do
    #     create_list(:exercise, 3, user: user)
    #     exercise
    #   end

    #   let(:exercise) { create(:simple_exercise, user: user) }


    # end
  end
end
