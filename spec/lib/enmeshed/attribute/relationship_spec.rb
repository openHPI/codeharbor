# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enmeshed::Attribute::Relationship do
  describe '#to_h' do
    subject(:attribute) { described_class.new(type:, key:, value:, owner:) }

    let(:type) { 'ProprietaryBoolean' }
    let(:key) { 'AllowCertificateRequest' }
    let(:value) { true }
    let(:owner) { 'id_of_the_owner' }

    it 'does not raise any error' do
      expect { attribute.to_h }.not_to raise_error
    end

    it 'returns the expected hash' do
      expect(attribute.to_h).to eq(
        '@type': 'RelationshipAttribute',
        key:,
        confidentiality: 'private',
        isTechnical: true,
        owner:,
        value: {
          '@type': type,
          title: I18n.t('users.nbp_wallet.enmeshed.AllowCertificateRequest'),
          value: true,
        }
      )
    end
  end
end
