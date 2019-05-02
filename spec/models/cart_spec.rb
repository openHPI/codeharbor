# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe '#add_exercise' do
    subject(:add_exercise) { cart.add_exercise(exercise) }

    let(:user) { create(:user) }
    let(:exercise) { create(:simple_exercise) }

    context 'when exercise not in cart' do
      let(:cart) { create(:cart, user: user, exercises: []) }

      it { is_expected.to be_truthy }

      it 'adds exercise' do
        expect { add_exercise }.to change(cart.exercises, :count).by(1)
      end
    end

    context 'when exercise not in cart' do
      let(:cart) { create(:cart, user: user, exercises: [exercise]) }

      it { is_expected.to be_falsey }

      it 'does not add when in cart already' do
        expect { add_exercise }.not_to change(cart.exercises, :count)
      end
    end
  end

  describe '#remove_exercise' do
    subject(:remove_exercise) { cart.remove_exercise(exercise) }

    let(:user) { create(:user) }
    let(:cart) { create(:cart, user: user, exercises: [exercise]) }
    let!(:exercise) { create(:simple_exercise) }

    it { is_expected.to be_truthy }

    it 'does not delete exercise' do
      expect { remove_exercise }.not_to change(Exercise, :count)
    end

    it 'removes exercise from group' do
      expect { remove_exercise }.to change(cart.exercises, :count).by(-1)
    end
  end

  describe '#destroy' do
    subject(:destroy) { cart.destroy }

    let(:user) { create(:user) }
    let!(:cart) { create(:cart, user: user, exercises: create_list(:simple_exercise, 2)) }

    it { is_expected.to be_truthy }

    it 'deletes cart' do
      expect { destroy }.to change(Cart, :count).by(-1)
    end

    it 'does not delete exercises' do
      expect { destroy }.not_to change(Exercise, :count)
    end
  end

  describe 'factories' do
    it 'has valid factory' do
      expect(FactoryBot.build_stubbed(:cart)).to be_valid
    end
  end
end
