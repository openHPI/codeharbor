# frozen_string_literal: true

require 'rails_helper'
require 'cgi'

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
      body = CGI.unescapeHTML(invitation_email.body.encoded)
      expect(body).to include(user.name)
      expect(body).to include(collection.title)
      expect(body).to include(I18n.t('collections.invitation_mailer.invitation_message', collection:))
    end

    context 'with different locales' do
      let(:locale) { 'de' }

      before do
        user.update(preferred_locale: locale)
      end

      it 'uses the user\'s preferred locale' do
        expect(invitation_email.body.encoded).to include('Sammlung')
        expect(invitation_email.subject).to include(I18n.t('collections.invitation_mailer.subject', collection:, locale:))
      end
    end
  end
end
