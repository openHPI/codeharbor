# frozen_string_literal: true

require 'rqrcode'

module Users
  class NbpWalletController < ApplicationController
    skip_after_action :verify_authorized

    def connect
      if Enmeshed::Relationship.pending_for(@provider_uid).present?
        redirect_to nbp_wallet_finalize_users_path and return
      end

      @relationship_template = Enmeshed::RelationshipTemplate.create!(nbp_uid: @provider_uid)
    rescue Enmeshed::ConnectorError, Faraday::Error => e
      Sentry.capture_exception(e)
      Rails.logger.debug { e }
      redirect_to new_user_registration_path, alert: t('common.errors.generic_try_later')
    end

    def qr_code
      truncated_reference = params[:truncated_reference]
      send_data Enmeshed::RelationshipTemplate.new(truncated_reference:).qr_code, type: 'image/png'
    end

    def relationship_status
      if Enmeshed::Relationship.pending_for(@provider_uid).present?
        render json: {status: :ready}
      else
        render json: {status: :waiting}
      end
    rescue Enmeshed::ConnectorError, Faraday::Error => e
      Sentry.capture_exception(e)
      Rails.logger.debug { e }
      redirect_to nbp_wallet_connect_users_path, alert: t('common.errors.generic')
    end

    def finalize
      relationship = Enmeshed::Relationship.pending_for(@provider_uid)
      return abort_and_refresh(relationship) if relationship.blank?

      accept_and_create_user(relationship)
    rescue Enmeshed::ConnectorError, Faraday::Error => e
      Sentry.capture_exception(e)
      Rails.logger.debug { e }
      abort_and_refresh(relationship)
    end

    private

    def accept_and_create_user(relationship) # rubocop:disable Metrics/AbcSize
      user = User.new_from_omniauth(relationship.userdata, 'nbp', @provider_uid)
      user.identities << UserIdentity.new(omniauth_provider: 'enmeshed', provider_uid: relationship.peer)
      user.skip_confirmation_notification!

      ApplicationRecord.transaction do
        unless user.save
          abort_and_refresh(
            relationship,
            t('common.errors.model_not_created', model: User.model_name.human, errors: user.errors.full_messages.join(', '))
          ) and raise ActiveRecord::Rollback
        end

        if relationship.accept!
          user.send_confirmation_instructions
          session.clear # Clear the session to prevent the user from accessing the NBP Wallet page again
          redirect_to home_index_path, notice: t('devise.registrations.signed_up_but_unconfirmed')
        else
          abort_and_refresh(relationship)
          raise ActiveRecord::Rollback
        end
      end
    end

    def abort_and_refresh(relationship, reason = t('common.errors.generic'))
      Rails.logger.debug { "NbpWalletController calling abort_and_refresh() due to: #{reason}" }
      relationship&.reject!
    rescue Enmeshed::ConnectorError, Faraday::Error => e
      # We still need to capture and handle an HTTP error caused by rejecting the template.
      Sentry.capture_exception(e)
      Rails.logger.debug { e }
    ensure
      redirect_to nbp_wallet_connect_users_path, alert: reason
    end

    def require_user!
      @provider_uid = session[:saml_uid]
      raise Pundit::NotAuthorizedError unless @provider_uid.present? && session[:omniauth_provider] == 'nbp'
      # Already registered users should not be able to access this page
      raise Pundit::NotAuthorizedError if User.joins(:identities)
        .exists?(identities: {omniauth_provider: 'nbp', provider_uid: @provider_uid})
    end
  end
end
