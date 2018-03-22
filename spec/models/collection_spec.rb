require 'rails_helper'

RSpec.describe Collection, type: :model do
  #pending "add some examples to (or delete) #{__FILE__}"
  describe 'Add Exercise' do
    let!(:user) {FactoryBot.create(:user)}
    let!(:exercise1) {FactoryBot.create(:simple_exercise)}
    let!(:exercise2) {FactoryBot.create(:simple_exercise)}
    let(:collection_with_one_exercise) {FactoryBot.create(:collection, users: [user], exercises: [exercise1] )}
    let(:collection_with_two_exercises) {FactoryBot.create(:collection, users: [user], exercises: [exercise1, exercise2] )}

    it 'should add when not in collection already' do
      collection = collection_with_one_exercise
      exercise_count = collection.exercises.count
      expect(collection.add_exercise(exercise2)).to be_truthy
      expect(collection.exercises.count).to eql(exercise_count + 1)
    end

    it 'should not add when in collection already' do
      collection = collection_with_two_exercises
      exercise_count = collection.exercises.count
      expect(collection.add_exercise(exercise2)).to be_falsey
      expect(collection.exercises.count).to eql(exercise_count)
    end
  end
  describe 'Destroy:' do
    let!(:user) {FactoryBot.create(:user)}
    let!(:exercise) {FactoryBot.create(:simple_exercise)}
    let!(:collection) {FactoryBot.create(:collection, users: [user], exercises: [exercise])}

    it 'delete exercise off collection when removing in collection' do
      exercises_count = Exercise.all.count
      collection_exercise_count = collection.exercises.count
      expect(collection.remove_exercise(exercise)).to be_truthy
      expect(collection.exercises.count).to eql(collection_exercise_count - 1)
      expect(Exercise.all.count).to eql(exercises_count)
    end

    it 'do not destroy actual exercises when collection gets destroyed' do
      exercises_count = Exercise.all.count
      collections_count = Collection.all.count
      expect(collection.destroy).to be_truthy
      expect(Collection.all.count).to eql(collections_count - 1)
      expect(Exercise.all.count).to eql(exercises_count)
    end

    it 'delete entry in collection, when exercise gets destroyed' do
      exercises_count = Exercise.all.count
      collection_exercise_count = collection.exercises.count
      expect(Exercise.find(exercise.id).destroy).to be_truthy
      expect(collection.exercises.count).to eql(collection_exercise_count - 1)
      expect(Exercise.all.count).to eql(exercises_count - 1)
    end

    it 'delete collections, when user gets destroyed' do
      collections_count = Collection.all.count
      expect(user.destroy).to be_truthy
      expect(Collection.all.count).to eql (collections_count - 1)
    end
  end
  describe 'factories' do
    it 'has valid factory' do
      expect(FactoryBot.build_stubbed(:collection)).to be_valid
    end

    it 'requires title' do
      expect(FactoryBot.build_stubbed(:collection, title: '')).not_to be_valid
    end
  end
end