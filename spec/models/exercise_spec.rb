# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe Exercise, type: :model do
  let(:user) { create(:user) }

  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:exercise_user) { create(:user) }
    let(:exercise) { create(:exercise, user: exercise_user, private: private?, authors: authors) }
    let(:private?) { false }
    let(:authors) { [] }

    it { is_expected.not_to be_able_to(:index, described_class) }
    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:contribute, described_class) }
    it { is_expected.not_to be_able_to(:read_comments, described_class) }
    it { is_expected.not_to be_able_to(:related_exercises, described_class) }
    it { is_expected.not_to be_able_to(:import_exercise_start, described_class) }
    it { is_expected.not_to be_able_to(:import_exercise_confirm, described_class) }

    it { is_expected.not_to be_able_to(:show, exercise) }
    it { is_expected.not_to be_able_to(:update, exercise) }
    it { is_expected.not_to be_able_to(:destroy, exercise) }
    it { is_expected.not_to be_able_to(:add_to_cart, exercise) }
    it { is_expected.not_to be_able_to(:add_to_collection, exercise) }
    it { is_expected.not_to be_able_to(:push_external, exercise) }
    it { is_expected.not_to be_able_to(:duplicate, exercise) }
    it { is_expected.not_to be_able_to(:download_exercise, exercise) }
    it { is_expected.not_to be_able_to(:contribute, exercise) }
    it { is_expected.not_to be_able_to(:read_comments, exercise) }
    it { is_expected.not_to be_able_to(:related_exercises, exercise) }

    it { is_expected.not_to be_able_to(:export_external_start, exercise) }
    it { is_expected.not_to be_able_to(:export_external_check, exercise) }
    it { is_expected.not_to be_able_to(:export_external_confirm, exercise) }
    it { is_expected.not_to be_able_to(:history, exercise) }
    it { is_expected.not_to be_able_to(:remove_state, exercise) }
    it { is_expected.not_to be_able_to(:report, exercise) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:index, described_class) }
      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:contribute, described_class) }
      it { is_expected.to be_able_to(:read_comments, described_class) }
      it { is_expected.to be_able_to(:related_exercises, described_class) }
      it { is_expected.to be_able_to(:import_exercise_start, described_class) }
      it { is_expected.to be_able_to(:import_exercise_confirm, described_class) }

      it { is_expected.to be_able_to(:show, exercise) }
      it { is_expected.to be_able_to(:add_to_cart, exercise) }
      it { is_expected.to be_able_to(:add_to_collection, exercise) }
      it { is_expected.to be_able_to(:push_external, exercise) }
      it { is_expected.to be_able_to(:duplicate, exercise) }
      it { is_expected.to be_able_to(:download_exercise, exercise) }
      it { is_expected.to be_able_to(:contribute, exercise) }
      it { is_expected.to be_able_to(:read_comments, exercise) }
      it { is_expected.to be_able_to(:related_exercises, exercise) }

      it { is_expected.not_to be_able_to(:update, exercise) }
      it { is_expected.not_to be_able_to(:destroy, exercise) }
      it { is_expected.not_to be_able_to(:export_external_start, exercise) }
      it { is_expected.not_to be_able_to(:export_external_check, exercise) }
      it { is_expected.not_to be_able_to(:export_external_confirm, exercise) }
      it { is_expected.not_to be_able_to(:history, exercise) }
      it { is_expected.not_to be_able_to(:remove_state, exercise) }
      it { is_expected.to be_able_to(:report, exercise) }

      context 'when exercise is private' do
        let(:private?) { true }

        it { is_expected.not_to be_able_to(:show, exercise) }
        it { is_expected.not_to be_able_to(:add_to_cart, exercise) }
        it { is_expected.not_to be_able_to(:add_to_collection, exercise) }
        it { is_expected.not_to be_able_to(:push_external, exercise) }
        it { is_expected.not_to be_able_to(:duplicate, exercise) }
        it { is_expected.not_to be_able_to(:download_exercise, exercise) }
        it { is_expected.to be_able_to(:contribute, exercise) }
        it { is_expected.to be_able_to(:read_comments, exercise) }
        it { is_expected.to be_able_to(:related_exercises, exercise) }

        it { is_expected.not_to be_able_to(:update, exercise) }
        it { is_expected.not_to be_able_to(:destroy, exercise) }
        it { is_expected.not_to be_able_to(:export_external_start, exercise) }
        it { is_expected.not_to be_able_to(:export_external_check, exercise) }
        it { is_expected.not_to be_able_to(:export_external_confirm, exercise) }
        it { is_expected.not_to be_able_to(:history, exercise) }
        it { is_expected.not_to be_able_to(:remove_state, exercise) }
        it { is_expected.to be_able_to(:report, exercise) }

        context 'when user is an author' do
          let(:authors) { [user] }

          it { is_expected.to be_able_to(:show, exercise) }
          it { is_expected.to be_able_to(:add_to_cart, exercise) }
          it { is_expected.to be_able_to(:add_to_collection, exercise) }
          it { is_expected.to be_able_to(:push_external, exercise) }
          it { is_expected.to be_able_to(:duplicate, exercise) }
          it { is_expected.to be_able_to(:download_exercise, exercise) }
          it { is_expected.to be_able_to(:contribute, exercise) }
          it { is_expected.to be_able_to(:read_comments, exercise) }
          it { is_expected.to be_able_to(:related_exercises, exercise) }

          it { is_expected.to be_able_to(:update, exercise) }
          it { is_expected.to be_able_to(:destroy, exercise) }
          it { is_expected.to be_able_to(:export_external_start, exercise) }
          it { is_expected.to be_able_to(:export_external_check, exercise) }
          it { is_expected.to be_able_to(:export_external_confirm, exercise) }
          it { is_expected.to be_able_to(:history, exercise) }
          it { is_expected.to be_able_to(:remove_state, exercise) }
          it { is_expected.not_to be_able_to(:report, exercise) }
        end

        context 'when exercise and user are member of a group' do
          before { create(:group, users: [user], exercises: [exercise]) }

          it { is_expected.to be_able_to(:show, exercise) }
          it { is_expected.to be_able_to(:add_to_cart, exercise) }
          it { is_expected.to be_able_to(:add_to_collection, exercise) }
          it { is_expected.to be_able_to(:push_external, exercise) }
          it { is_expected.to be_able_to(:duplicate, exercise) }
          it { is_expected.to be_able_to(:download_exercise, exercise) }
          it { is_expected.to be_able_to(:contribute, exercise) }
          it { is_expected.to be_able_to(:read_comments, exercise) }
          it { is_expected.to be_able_to(:related_exercises, exercise) }

          it { is_expected.not_to be_able_to(:update, exercise) }
          it { is_expected.not_to be_able_to(:destroy, exercise) }
          it { is_expected.not_to be_able_to(:export_external_start, exercise) }
          it { is_expected.not_to be_able_to(:export_external_check, exercise) }
          it { is_expected.not_to be_able_to(:export_external_confirm, exercise) }
          it { is_expected.not_to be_able_to(:history, exercise) }
          it { is_expected.not_to be_able_to(:remove_state, exercise) }
          it { is_expected.to be_able_to(:report, exercise) }
        end
      end

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, exercise) }
      end

      context 'when exercise is from user' do
        let(:exercise_user) { user }

        it { is_expected.not_to be_able_to(:manage, described_class) }
        it { is_expected.not_to be_able_to(:manage, exercise) }

        it { is_expected.to be_able_to(:show, exercise) }
        it { is_expected.to be_able_to(:add_to_cart, exercise) }
        it { is_expected.to be_able_to(:add_to_collection, exercise) }
        it { is_expected.to be_able_to(:push_external, exercise) }
        it { is_expected.to be_able_to(:duplicate, exercise) }
        it { is_expected.to be_able_to(:download_exercise, exercise) }
        it { is_expected.to be_able_to(:contribute, exercise) }
        it { is_expected.to be_able_to(:read_comments, exercise) }
        it { is_expected.to be_able_to(:related_exercises, exercise) }

        it { is_expected.to be_able_to(:update, exercise) }
        it { is_expected.to be_able_to(:destroy, exercise) }
        it { is_expected.to be_able_to(:export_external_start, exercise) }
        it { is_expected.to be_able_to(:export_external_check, exercise) }
        it { is_expected.to be_able_to(:export_external_confirm, exercise) }
        it { is_expected.to be_able_to(:history, exercise) }
        it { is_expected.to be_able_to(:remove_state, exercise) }
        it { is_expected.not_to be_able_to(:report, exercise) }
      end
    end
  end

  describe '#valid?' do
    it { is_expected.to validate_presence_of(:descriptions) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:uuid).case_insensitive }
    it { is_expected.to validate_presence_of(:execution_environment) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:predecessor).optional }

    # one_primary_description
    context 'when exercise has a description' do
      subject { build(:exercise, descriptions: descriptions) }

      let(:descriptions) { [description] }
      let(:description) { build(:description) }

      it { is_expected.not_to be_valid }

      context 'when description is primary' do
        let(:description) { build(:description, primary: true) }

        it { is_expected.to be_valid }

        context 'with multiple descriptions' do
          let(:descriptions) { [description, build(:description)] }

          it { is_expected.to be_valid }
        end

        context 'with multiple primary descriptions' do
          let(:descriptions) { [description, build(:description, primary: true)] }

          it { is_expected.not_to be_valid }
        end
      end
    end

    context 'when exercise is private' do
      subject { build(:exercise, private: true) }

      it { is_expected.not_to validate_presence_of(:license) }
      it { is_expected.not_to validate_presence_of(:execution_environment) }
    end

    context 'when exercise is public' do
      subject { build(:exercise, private: false) }

      it { is_expected.to validate_presence_of(:license) }
    end

    context 'when an exercise with predecessor exists' do
      subject { exercise }

      let(:exercise) { create(:exercise, predecessor: predecessor) }
      let(:predecessor) { create(:exercise) }

      it { is_expected.to be_valid }

      # no_predecessor_loop
      context 'when predecessor has first exercise as predecessor' do
        before { predecessor.assign_attributes(predecessor: exercise) }

        it { is_expected.not_to be_valid }
      end
    end

    context 'with a main_file' do
      subject { build(:exercise, exercise_files: exercise_files) }

      let(:exercise_files) { [build(:codeharbor_main_file)] }

      it { is_expected.to be_valid }

      context 'with two main_files' do
        let(:exercise_files) { [build(:codeharbor_main_file), build(:codeharbor_main_file)] }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe '#add_attributes' do
    let(:exercise) { create(:only_meta_data, :with_primary_description, downloads: downloads) }
    let(:downloads) { 0 }
    let(:file_type) { create(:file_type) }
    let(:tests) { Test.where(exercise_id: exercise.id) }
    let(:files) { ExerciseFile.where(exercise_id: exercise.id) }
    let(:descriptions) { Description.where(exercise_id: exercise.id) }

    context 'when params attributes are nil' do
      subject(:add_empty_attributes) do
        exercise.add_attributes(params, user)
        exercise.save
      end

      let(:params) { {tests_attributes: nil, exercise_files_attributes: nil, descriptions_attributes: nil} }

      it { expect { add_empty_attributes }.not_to(change(tests, :size)) }
      it { expect { add_empty_attributes }.not_to(change(files, :size)) }
      it { expect { add_empty_attributes }.not_to(change(descriptions, :size)) }
    end

    context 'when params attributes are set' do
      subject(:add_attributes) do
        exercise.add_attributes(params, user)
        exercise.save!
      end

      before { group.add(user, as: :member) }

      let(:license) { create(:license) }
      let(:relation) { create(:relation) }
      let(:group) { create(:group) }
      let(:exercise_relation_param) {}
      let(:params) do
        ActionController::Parameters.new(
          exercise_relation: exercise_relation_param,
          groups: ['', group.id],
          labels: ['', create(:label).name],
          license_id: license.id,
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
              testing_framework_id: create(:testing_framework).id
            }
          },
          exercise_files_attributes: {
            '0' => {
              role: 'main_file',
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

      it 'sets the license' do
        expect { add_attributes }.to change(exercise.reload, :license).to(license)
      end

      context 'when exercise already has downloads' do
        let(:downloads) { 1 }

        it 'does not set the license' do
          expect { add_attributes }.not_to change(exercise.reload, :license)
        end
      end

      context 'with exercise_relation param' do
        let(:origin_exercise) { create(:exercise) }
        let(:exercise_relation_param) { {relation_id: relation.id, origin_id: origin_exercise.id} }

        # rubocop:disable RSpec/MultipleExpectations
        it 'sets the exercise_relation' do
          expect(exercise.clone_relations).to be_empty
          add_attributes
          expect(exercise.clone_relations).not_to be_empty
        end
        # rubocop:enable RSpec/MultipleExpectations

        it 'does not set the license' do
          expect { add_attributes }.to change(exercise.reload, :license).to(origin_exercise.license)
        end
      end

      it 'sets the label' do
        expect { add_attributes }.to change(exercise.reload.labels, :size).by(1)
      end

      it 'sets the group' do
        expect { add_attributes }.to change(exercise.reload.groups, :size).by(1)
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
    subject { described_class.search(search, settings, option, user_param) }

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
        let(:exercise) { create(:simple_exercise, user: user, descriptions: [build(:simple_description, :primary, text: 'filtertext')]) }
        let(:search) { 'filtertext' }

        it { is_expected.to include exercise }
      end
    end
  end

  describe '.active' do
    subject(:active) { described_class.active }

    it { is_expected.to be_empty }

    context 'when a normal exercise exists' do
      let(:exercise) { create(:exercise) }

      before { exercise }

      it { is_expected.to include(exercise) }

      context 'when the exercise has a predecessor' do
        let(:predecessor) { create(:exercise, successor: exercise) }

        before { predecessor }

        it { is_expected.to contain_exactly(exercise) }
      end
    end
  end

  describe '#destroy' do
    let(:user) { create(:user) }
    let!(:exercise) { create(:simple_exercise, user: user) }

    it 'deletes exercise' do
      expect { exercise.destroy }.to change(described_class, :count).by(-1)
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

  # rubocop:disable RSpec/ExampleLength
  describe '#save_old_version' do
    subject(:save_old_version) { exercise.save_old_version }

    let!(:exercise) { create(:complex_exercise).reload }

    it 'creates the predecessor of the exercise' do
      expect { save_old_version }.to change { exercise.reload.predecessor }.from(nil).to(be_a described_class)
    end

    it 'creates a new Exercise' do
      expect { save_old_version }.to change(described_class, :count).by(1)
    end

    it 'creates the predecessor with correct attributes' do
      save_old_version
      expect(exercise.reload.predecessor).to have_attributes(
        title: exercise.title,
        descriptions: have(exercise.descriptions.count).item.and(include(have_attributes(
                                                                           text: exercise.descriptions.first.text,
                                                                           language: exercise.descriptions.first.language
                                                                         ))),
        execution_environment: eql(exercise.execution_environment),
        license: eql(exercise.license),
        exercise_files: have(exercise.exercise_files.count).items,
        tests: have(exercise.tests.count).items
      )
    end

    it 'duplicates whole exercise' do
      save_old_version
      expect(exercise).to be_an_equal_exercise_as exercise.reload.predecessor
    end

    it 'does not copy critical values' do
      save_old_version
      expect(exercise.reload.predecessor).not_to have_attributes(
        id: exercise.id,
        uuid: exercise.uuid,
        created_at: exercise.created_at,
        updated_at: exercise.updated_at
      )
    end

    context 'when exercise already has a predecessor' do
      before { exercise.save_old_version }

      it 'creates a third exercise for the history' do
        expect { save_old_version }.to change { exercise.reload.complete_history.count }.from(2).to(3)
      end

      it 'creates another predecessor' do
        save_old_version
        expect(exercise.reload.predecessor.predecessor).to be_a described_class
      end
    end

    context 'when update of predecessor fails' do
      before do
        root_exercise = described_class.find(exercise.id)
        allow(described_class).to receive(:find).with(exercise.id).and_return(root_exercise)
        allow(root_exercise).to receive(:update!).and_raise('an error')
      end

      it 'does not create the predecessor of the exercise' do
        expect { save_old_version }.not_to(change { exercise.reload.predecessor })
      end

      it 'does not create a new Exercise' do
        expect { save_old_version }.to change(described_class, :count).by(1)
      end
    end

    context 'when some values have already been changed' do
      before { exercise.title = 'new_title' }

      it 'creates the predecessor with the old attributes' do
        save_old_version
        expect(exercise.reload.predecessor.title).not_to eql 'new_title'
      end

      it 'does not change attributes of exercise itself' do
        save_old_version
        expect(exercise.title).to eql 'new_title'
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength

  describe '#duplicate' do
    subject(:duplicate) { exercise.duplicate }

    let(:exercise) do
      create(
        :exercise,
        private: private,
        descriptions: descriptions,
        tests: tests,
        exercise_files: exercise_files
      )
    end
    let(:private) { true }
    let(:descriptions) { [description] }
    let(:description) { build(:description, primary: true) }
    let(:tests) { [test] }
    let(:test) { build(:codeharbor_test) }
    let(:exercise_files) { [exercise_file] }
    let(:exercise_file) { build(:exercise_file) }

    it 'copies private attribute from exercise' do
      expect(duplicate.private).to eql exercise.private
    end

    it 'copies description from exercise and does not use the same object' do
      expect(duplicate.descriptions).not_to match_array(descriptions)
    end

    it 'copies description with correct attributes' do
      expect(duplicate.descriptions).to include(have_attributes(text: description.text, primary: description.primary))
    end

    it 'copies test from exercise and does not use the same object' do
      expect(duplicate.tests).not_to match_array(tests)
    end

    it 'copies test with correct attributes' do
      expect(duplicate.tests).to include(have_attributes(feedback_message: test.feedback_message))
    end

    it 'copies exercise_file from exercise and does not use the same object' do
      expect(duplicate.exercise_files).not_to match_array(exercise_files)
    end

    it 'copies exercise_file with correct attributes' do
      expect(duplicate.exercise_files).to include(
        have_attributes(content: exercise_file.content,
                        name: exercise_file.name,
                        role: exercise_file.role)
      )
    end

    context 'when private is false' do
      let(:private) { false }

      it 'copies private attribute from exercise' do
        expect(duplicate.private).to eql exercise.private
      end
    end
  end

  describe '#last_successor' do
    let!(:exercise) { create(:exercise, predecessor: predecessor) }
    let(:predecessor) {}

    it 'returns self' do
      expect(exercise.last_successor).to eql exercise
    end

    context 'when exercise has a history' do
      let(:predecessor) { create(:exercise) }

      it 'returns correct successor' do
        expect(predecessor.last_successor).to eql exercise
      end

      context 'when history is large' do
        let(:last_predecessor) { create(:exercise) }

        before do
          predecessor.update(
            predecessor: create(:exercise, predecessor: last_predecessor)
          )
        end

        it 'returns the correct last successor' do
          expect(last_predecessor.last_successor).to eql exercise
        end

        it 'returns the correct last_successor' do
          expect(predecessor.last_successor).to eql exercise
        end
      end
    end
  end

  describe '#complete_history' do
    let!(:exercise) { create(:exercise, predecessor: predecessor) }
    let(:predecessor) {}

    it 'returns correct history' do
      expect(exercise.complete_history).to contain_exactly exercise
    end

    context 'when exercise has a history' do
      let(:predecessor) { create(:exercise) }

      it 'returns correct history' do
        expect(predecessor.complete_history).to contain_exactly exercise, predecessor
      end

      context 'when history is large' do
        let(:last_predecessor) { create(:exercise) }

        before { predecessor.update(predecessor: last_predecessor) }

        it 'returns correct history' do
          expect(last_predecessor.complete_history)
            .to(contain_exactly(exercise, predecessor, last_predecessor)
              .and(match_array(predecessor.complete_history)
                .and(match_array(exercise.complete_history))))
        end
      end
    end
  end

  describe '#all_predecessors' do
    let!(:exercise) { create(:exercise, predecessor: predecessor) }
    let(:predecessor) {}

    it 'returns nothing' do
      expect(exercise.all_predecessors).to be_empty
    end

    context 'when exercise has a history' do
      let(:predecessor) { create(:exercise) }

      it 'returns the only predecessor' do
        expect(exercise.all_predecessors).to contain_exactly predecessor
      end

      context 'when history is large' do
        let(:last_predecessor) { create(:exercise) }

        before { predecessor.update(predecessor: last_predecessor) }

        it 'returns both predecessors' do
          expect(exercise.all_predecessors).to(contain_exactly(predecessor, last_predecessor))
        end

        it 'returns the only predecessor' do
          expect(predecessor.all_predecessors).to(contain_exactly(last_predecessor))
        end
      end
    end
  end

  describe '#update_and_version' do
    subject(:update_and_version) { exercise.update_and_version(params, {}, user) }

    let!(:exercise) { create(:exercise) }
    let(:params) { {title: 'new_title'} }

    it { is_expected.to be true }

    it 'updates exercise' do
      expect { update_and_version }.to change { exercise.reload.title }.to('new_title')
    end

    it 'creates new exercise' do
      expect { update_and_version }.to change(described_class, :count).by(1)
    end

    it 'creates new exercise as predecessor of exercise' do
      update_and_version
      expect(described_class.last).to eql exercise.reload.predecessor
    end

    it 'does not change the title of predecessor' do
      update_and_version
      expect(exercise.reload.predecessor.title).not_to eql('new_title')
    end

    context 'when invalid params are given' do
      let(:params) { {descriptions: [], title: 'new_title'} }

      it { is_expected.to be false }

      it 'does not update exercise' do
        expect { update_and_version }.not_to(change { exercise.reload.title })
      end

      it 'does not create new exercise' do
        expect { update_and_version }.not_to change(described_class, :count)
      end
    end
  end

  describe '#soft_delete' do
    subject(:soft_delete) { exercise.soft_delete }

    let(:group) { create(:group) }
    let(:cart) { create(:cart) }
    let(:collection) { create(:collection) }
    let(:relation) { create(:exercise_relation) }
    let(:exercise) { create(:exercise, groups: [group], carts: [cart], collections: [collection], clone_relations: [relation]) }

    it 'sets deleted to true' do
      expect { soft_delete }.to change(exercise.reload, :deleted).to(true)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'removes group from exercise' do
      expect(exercise.groups).not_to be_empty
      soft_delete
      expect(exercise.groups).to be_empty
    end

    it 'removes collection from exercise' do
      expect(exercise.collections).not_to be_empty
      soft_delete
      expect(exercise.collections).to be_empty
    end

    it 'removes cart from exercise' do
      expect(exercise.carts).not_to be_empty
      soft_delete
      expect(exercise.carts).to be_empty
    end

    it 'removes clone_relation from exercise' do
      expect(exercise.clone_relations).not_to be_empty
      soft_delete
      expect(exercise.clone_relations).to be_empty
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe '#initialize_derivate' do
    subject(:initialize_derivate) { exercise.initialize_derivate }

    let(:exercise) { create(:exercise) }
    let!(:derivate_relation) { create(:relation, name: 'Derivate') }

    it 'copies most attributes from exercise' do
      expect(initialize_derivate)
        .to have_attributes(exercise.attributes.except('id', 'created_at', 'updated_at', 'uuid', 'predecessor_id', 'state_list'))
    end

    it 'sets up a relation' do
      expect(initialize_derivate.clone_relations).to include have_attributes(origin: exercise, relation: derivate_relation)
    end

    context 'when user param is set' do
      subject(:initialize_derivate) { exercise.initialize_derivate(user) }

      let(:user) { create(:user) }

      it 'sets the user' do
        expect(initialize_derivate.user).to be user
      end
    end
  end

  describe '#updatable_by?' do
    subject(:updatable_by?) { exercise.updatable_by?(user_param) }

    let(:user_param) { user }
    let(:user) { create(:user) }
    let(:exercise) { create(:exercise, user: user) }

    it { is_expected.to be true }

    context 'when user param is another user' do
      let(:user_param) { create(:user) }

      it { is_expected.to be false }

      context 'when the another user is author' do
        let(:user_param) { author_user }
        let(:author_user) { create(:user) }

        before { exercise.authors << author_user }

        it { is_expected.to be true }
      end
    end
  end
end
