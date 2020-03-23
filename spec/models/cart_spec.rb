# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:cart_user) { create(:user) }
    let(:cart) { create(:cart, user: cart_user) }

    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:new, described_class) }
    it { is_expected.not_to be_able_to(:manage, described_class) }

    it { is_expected.not_to be_able_to(:my_cart, cart) }
    it { is_expected.not_to be_able_to(:show, cart) }
    it { is_expected.not_to be_able_to(:remove_all, cart) }
    it { is_expected.not_to be_able_to(:download_all, cart) }
    it { is_expected.not_to be_able_to(:push_cart, cart) }
    it { is_expected.not_to be_able_to(:export, cart) }
    it { is_expected.not_to be_able_to(:remove_exercise, cart) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:new, described_class) }
      it { is_expected.not_to be_able_to(:manage, described_class) }

      it { is_expected.not_to be_able_to(:my_cart, cart) }
      it { is_expected.not_to be_able_to(:show, cart) }
      it { is_expected.not_to be_able_to(:remove_all, cart) }
      it { is_expected.not_to be_able_to(:download_all, cart) }
      it { is_expected.not_to be_able_to(:push_cart, cart) }
      it { is_expected.not_to be_able_to(:export, cart) }
      it { is_expected.not_to be_able_to(:remove_exercise, cart) }

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, cart) }
      end

      context 'when cart is from user' do
        let(:cart_user) { user }

        it { is_expected.not_to be_able_to(:manage, described_class) }

        it { is_expected.not_to be_able_to(:manage, cart) }
        it { is_expected.to be_able_to(:my_cart, cart) }
        it { is_expected.to be_able_to(:show, cart) }
        it { is_expected.to be_able_to(:remove_all, cart) }
        it { is_expected.to be_able_to(:download_all, cart) }
        it { is_expected.to be_able_to(:push_cart, cart) }
        it { is_expected.to be_able_to(:export, cart) }
        it { is_expected.to be_able_to(:remove_exercise, cart) }
      end
    end
  end

  describe '#valid?' do
    it { is_expected.to belong_to(:user) }
  end

  describe '#add_exercise' do
    subject(:add_exercise) { cart.add_exercise(exercise) }

    let(:user) { create(:user) }
    let(:exercise) { create(:simple_exercise) }

    context 'when exercise is not in cart' do
      let(:cart) { create(:cart, user: user, exercises: []) }

      it { is_expected.to be_truthy }

      it 'adds exercise' do
        expect { add_exercise }.to change(cart.exercises, :count).by(1)
      end
    end

    context 'when exercise is in cart' do
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
      expect { destroy }.to change(described_class, :count).by(-1)
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
