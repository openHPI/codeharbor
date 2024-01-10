# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class.new(current_user, user) }

  let(:user) { create(:user) }

  context 'without a current_user' do
    it { expect { described_class.new(nil, user) }.to raise_error(Pundit::NotAuthorizedError) }
  end

  context 'with a current_user' do
    let(:current_user) { create(:user) }

    it { is_expected.to permit_only_actions(%i[message]) }

    context 'when current_user is admin' do
      let(:current_user) { create(:admin) }

      it { is_expected.to permit_all_actions }
    end

    context 'when current_user is user' do
      let(:user) { current_user }

      it { is_expected.to forbid_only_actions(%i[message]) }
    end
  end
end
