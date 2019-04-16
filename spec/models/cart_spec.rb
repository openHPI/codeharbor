# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'Add Exercise' do
    let!(:user1) { FactoryBot.create(:user) }
    let!(:user2) { FactoryBot.create(:user) }
    let!(:exercise1) { FactoryBot.create(:simple_exercise) }
    let!(:exercise2) { FactoryBot.create(:simple_exercise) }
    let(:cart_with_one_exercise) { FactoryBot.create(:cart, user: user1, exercises: [exercise1]) }
    let(:cart_with_two_exercises) { FactoryBot.create(:cart, user: user2, exercises: [exercise1, exercise2]) }

    it 'adds when not in cart already' do
      cart = cart_with_one_exercise
      exercise_count = cart.exercises.count
      expect(cart.add_exercise(exercise2)).to be_truthy
      expect(cart.exercises.count).to eql(exercise_count + 1)
    end

    it 'does not add when in cart already' do
      cart = cart_with_two_exercises
      exercise_count = cart.exercises.count
      expect(cart.add_exercise(exercise2)).to be_falsey
      expect(cart.exercises.count).to eql(exercise_count)
    end
  end

  describe 'Destroy:' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:exercise) { FactoryBot.create(:simple_exercise) }
    let!(:cart) { FactoryBot.create(:cart, user: user, exercises: [exercise]) }

    it 'delete exercise from cart' do
      exercises_count = Exercise.all.count
      cart_exercise_count = cart.exercises.count
      expect(cart.remove_exercise(exercise)).to be_truthy
      expect(cart.exercises.count).to eql(cart_exercise_count - 1)
      expect(Exercise.all.count).to eql(exercises_count)
    end

    it 'do not destroy actual exercises when cart gets destroyed' do
      exercises_count = Exercise.all.count
      cart_count = Cart.all.count
      expect(cart.destroy).to be_truthy
      expect(Cart.all.count).to eql(cart_count - 1)
      expect(Exercise.all.count).to eql(exercises_count)
    end

    it 'delete entry in cart, when exercise gets destroyed' do
      exercises_count = Exercise.all.count
      cart_exercise_count = cart.exercises.count
      expect(Exercise.find(exercise.id).destroy).to be_truthy
      expect(cart.exercises.count).to eql(cart_exercise_count - 1)
      expect(Exercise.all.count).to eql(exercises_count - 1)
    end

    it 'delete cart, when user gets destroyed' do
      cart_count = Cart.all.count
      expect(user.destroy).to be_truthy
      expect(Cart.all.count).to eql(cart_count - 1)
    end
  end

  describe 'factories' do
    it 'has valid factory' do
      expect(FactoryBot.build_stubbed(:cart)).to be_valid
    end
  end
end
