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
      let(:params) { { tests_attributes: nil, exercise_files_attributes: nil, descriptions_attributes: nil } }

      it 'does not add anything new' do
        exercise.add_attributes(params)
        expect(tests.size).to be 0
        expect(files.size).to be 0
        expect(descriptions.size).to be 1
      end
    end

    context 'when params attributes are set' do
      let(:params) do
        ActionController::Parameters.new(
          tests_attributes: {
            '0' => {
              exercise_file_attributes: {
                name: 'test', file_type_id: file_type.id, content: 'this is some test'
              },
              feedback_message: 'not_working',
              _destroy: false,
              testing_framework: { name: 'pytest', id: '12345678' }
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
      it 'adds stuff' do
        # params = ActionController::Parameters.new({})
        exercise.add_attributes(params)
        exercise.save
        expect(tests.size).to be 1
        expect(files.size).to be 2 # Actual file and test.exercise_file
        expect(tests[0].exercise_file).to be_truthy
        expect(descriptions.size).to be 2
      end
    end
  end
end
