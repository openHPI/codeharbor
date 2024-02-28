# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  render_views

  describe '#render_not_authorized' do
    before do
      allow(controller).to receive(:index) { controller.send(:render_not_authorized) }
      sign_in user if defined?(user)
      get :index
    end

    expect_flash_message(:alert, I18n.t('common.errors.not_signed_in'))
    expect_redirect(:new_user_session)

    context 'with an admin' do
      let(:user) { create(:admin) }

      expect_flash_message(:alert, I18n.t('common.errors.not_authorized'))
      expect_redirect(:root)
    end

    context 'with an user' do
      let(:user) { create(:user) }

      expect_flash_message(:alert, I18n.t('common.errors.not_authorized'))
      expect_redirect(:root)
    end
  end

  describe '#render_not_found' do
    before do
      allow(controller).to receive(:index) { controller.send(:render_not_found) }
      sign_in(user) if defined?(user)
      get :index
    end

    expect_flash_message(:alert, I18n.t('common.errors.not_signed_in'))
    expect_redirect(:new_user_session)

    context 'with an admin' do
      let(:user) { create(:admin) }

      expect_flash_message(:alert, I18n.t('common.errors.not_found_error'))
      expect_redirect(:root)
    end

    context 'with an user' do
      let(:user) { create(:user) }

      expect_flash_message(:alert, I18n.t('common.errors.not_authorized'))
      expect_redirect(:root)
    end
  end

  describe '#switch_locale' do
    subject(:get_request) { get :index, params: {locale:} }

    let(:locale) { nil }
    let(:user) { nil }

    shared_examples 'locale assignment' do |expected_locale|
      before { get_request }

      it "sets session locale to #{expected_locale}" do
        expect(session[:locale]&.to_sym).to be(expected_locale)
      end

      it "sets users preferred locale to #{expected_locale}" do
        if user.present?
          expect(user.reload.preferred_locale.to_sym).to eq(expected_locale)
        end
      end
    end

    context 'when not signed in' do
      context 'when specifying a locale' do
        let(:locale) { :de }

        it_behaves_like 'locale assignment', :de
      end

      context "with a 'locale' value in the session" do
        before { session[:locale] = :de }

        it_behaves_like 'locale assignment', :de
      end

      context "without a 'locale' value in the session" do
        it_behaves_like 'locale assignment', I18n.default_locale
      end

      context 'when specifying an invalid locale' do
        let(:locale) { :invalid }

        it_behaves_like 'locale assignment', I18n.default_locale

        context 'when session locale is valid' do
          before { session[:locale] = :de }

          it_behaves_like 'locale assignment', :de
        end
      end
    end

    context 'when signed in' do
      before { sign_in user }

      let!(:user) { create(:user, preferred_locale: :en) }

      context 'when specifying a locale' do
        let(:locale) { :de }

        it_behaves_like 'locale assignment', :de
      end

      context "with a 'locale' value in the session" do
        before { session[:locale] = :de }

        it_behaves_like 'locale assignment', :de
      end

      context "without a 'locale' value in the session" do
        context 'when user has preferred locale' do
          before { user.update(preferred_locale: :de) }

          it_behaves_like 'locale assignment', :de
        end
      end

      context 'when specifying an invalid locale' do
        let(:locale) { :invalid }

        it_behaves_like 'locale assignment', I18n.default_locale

        context 'when session locale is valid' do
          before { session[:locale] = :de }

          it_behaves_like 'locale assignment', :de
        end

        context 'when user has preferred locale' do
          before { user.update(preferred_locale: :de) }

          it_behaves_like 'locale assignment', :de
        end
      end
    end
  end

  describe 'GET #index' do
    before { get :index }

    expect_http_status(:ok)
    expect_template(:index)
  end
end
