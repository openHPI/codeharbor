# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionPolicy do
  subject { described_class.new(user, collection) }

  let(:user) { nil }
  let(:collection_user) { create(:user) }
  let(:collection) { create(:collection, users:) }
  let(:users) { [collection_user] }

  context 'with a user' do
    let(:user) { create(:user) }

    it { is_expected.to permit_only_actions(%i[index new]) }

    context 'when user is admin' do
      let(:user) { create(:admin) }

      it { is_expected.to permit_all_actions }
    end

    context 'when collection is from user' do
      let(:collection_user) { user }

      it { is_expected.to forbid_only_actions(%i[save_shared]) }
    end
  end
end
