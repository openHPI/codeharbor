# frozen_string_literal: true

class AccessRequestMailer < ApplicationMailer
  def send_access_request
    @user = params.fetch(:user)
    @admin = params.fetch(:admin)
    @group = params.fetch(:group)

    I18n.with_locale(@admin.preferred_locale || I18n.default_locale) do
      mail(to: @admin.email, subject: t('groups.access_request_mailer.subject', user: @user.name, group: @group.name))
    end
  end
end
