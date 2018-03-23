require 'rails_helper'
require 'nokogiri'

RSpec.describe Exercise, type: :model do
  describe 'test creation' do
    context 'and adding description, tasks and tests' do
      let(:exercise){FactoryBot.create(:only_meta_data)}
      let(:file_type){FactoryBot.create(:file_type)}

      it 'does not add anything new' do
        params = {:tests_attributes => nil, :exercise_files_attributes => nil, :descriptions_attributes => nil}
        exercise.add_attributes(params)
        tests = Test.where(exercise_id: exercise.id)
        files = ExerciseFile.where(exercise_id: exercise.id)
        descriptions = Description.where(exercise_id: exercise.id)
        expect(tests.size()).to be 0
        expect(files.size()).to be 0
        expect(descriptions.size()).to be 1
      end
      
      it 'adds stuff' do

        params = ActionController::Parameters.new({
          :tests_attributes => 
            {"0" => {name: 'test', file_type_id: file_type.id , :content =>'this is some test', :feedback_message => 'not_working', :_destroy => false, :testing_framework => {:name => 'pytest', :id => '12345678'}}},
          :exercise_files_attributes =>
            {"0" => {:role => 'Main File', :content => 'some new exercise', :path => 'some/path/', :purpose => 'a new purpose',
              :name => 'awesome', :file_type_id => file_type.id, :_destroy => false}},
          :descriptions_attributes =>
            {"0" => {:text => 'a new description', :language => 'de', :_destroy => false}}})
        exercise.add_attributes(params)
        exercise.save
        tests = Test.where(exercise_id: exercise.id)
        test = tests[0]
        files = ExerciseFile.where(exercise_id: exercise.id)
        descriptions = Description.where(exercise_id: exercise.id)
        expect(tests.size()).to be 1
        expect(files.size()).to be 1 #Only actual file
        expect(test.exercise_file).to be_truthy
        expect(descriptions.size()).to be 2
      end
    end
  end
end
