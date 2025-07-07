# frozen_string_literal: true

class CollectionInvitationMailer < ApplicationMailer
  def send_invitation
    @collection = params.fetch(:collection)
    @recipient = params.fetch(:recipient)

    I18n.with_locale(@recipient.preferred_locale || I18n.default_locale) do
      mail(to: @recipient.email, subject: t('collections.invitation_mailer.subject', collection: @collection.title))
    end
  end
end
