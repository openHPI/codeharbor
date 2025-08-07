# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionInvitationMailer do
  describe '#send_invitation' do
    subject(:invitation_email) { described_class.with(collection:, recipient: user).send_invitation }

    let(:collection) { create(:collection) }
    let(:user) { create(:user) }

    it 'sends an email to the correct recipient' do
      expect(invitation_email.to).to include(user.email)
    end

    it 'has the correct subject' do
      expect(invitation_email.subject).to include(collection.title)
    end

    it 'contains the correct content' do
      expect(invitation_email.body.encoded).to include(user.name)
      expect(invitation_email.body.encoded).to include(collection.title)
      expect(invitation_email.body.encoded).to include('collaborate')
    end

    context 'with different locales' do
      before do
        user.update(preferred_locale: 'de')
      end

      it 'uses the user\'s preferred locale' do
        expect(invitation_email.body.encoded).to include('Sammlung')
        expect(invitation_email.subject).to include('Einladung zur Sammlung')
      end
    end
  end
end
