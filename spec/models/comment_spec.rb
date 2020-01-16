# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user) { nil }
    let(:comment_user) { create(:user) }
    let(:comment) { create(:comment, user: comment_user) }

    it { is_expected.not_to be_able_to(:create, described_class) }
    it { is_expected.not_to be_able_to(:new, described_class) }
    it { is_expected.not_to be_able_to(:manage, described_class) }

    it { is_expected.not_to be_able_to(:show, comment) }
    it { is_expected.not_to be_able_to(:read, comment) }
    it { is_expected.not_to be_able_to(:answer, comment) }
    it { is_expected.not_to be_able_to(:update, comment) }
    it { is_expected.not_to be_able_to(:destroy, comment) }

    context 'with a user' do
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:create, described_class) }
      it { is_expected.to be_able_to(:new, described_class) }
      it { is_expected.not_to be_able_to(:manage, described_class) }

      it { is_expected.to be_able_to(:show, comment) }
      it { is_expected.to be_able_to(:read, comment) }
      it { is_expected.to be_able_to(:answer, comment) }
      it { is_expected.not_to be_able_to(:update, comment) }
      it { is_expected.not_to be_able_to(:destroy, comment) }

      context 'when user is admin' do
        let(:user) { create(:admin) }

        it { is_expected.to be_able_to(:manage, described_class) }
        it { is_expected.to be_able_to(:manage, comment) }
      end

      context 'when comment is from user' do
        let(:comment_user) { user }

        it { is_expected.not_to be_able_to(:manage, described_class) }

        it { is_expected.to be_able_to(:show, comment) }
        it { is_expected.to be_able_to(:read, comment) }
        it { is_expected.to be_able_to(:answer, comment) }
        it { is_expected.to be_able_to(:update, comment) }
        it { is_expected.to be_able_to(:destroy, comment) }
      end
    end
  end

  describe '#valid?' do
    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:exercise) }
  end
end
