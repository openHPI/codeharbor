# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  render_views

  describe '#render_not_authorized' do
    before do
      allow(controller).to receive(:index) { controller.send(:render_not_authorized) }
      get :index
    end

    expect_flash_message(:alert, I18n.t('common.errors.not_authorized'))
    expect_redirect(:root)
  end

  describe '#render_not_found' do
    before do
      allow(controller).to receive(:index) { controller.send(:render_not_found) }
      sign_in(user) if defined?(user)
      get :index
    end

    expect_flash_message(:alert, I18n.t('common.errors.not_authorized'))
    expect_redirect(:root)

    context 'with an admin' do
      let(:user) { create(:admin) }

      expect_flash_message(:alert, I18n.t('common.errors.not_found_error'))
    end

    context 'with an user' do
      let(:user) { create(:user) }

      expect_flash_message(:alert, I18n.t('common.errors.not_authorized'))
    end
  end

  describe '#switch_locale' do
    let(:locale) { :en }

    context 'when specifying a locale' do
      before { allow(session).to receive(:[]=).at_least(:once) }

      context "when using the 'custom_locale' parameter" do
        it 'overwrites the session' do
          expect(session).to receive(:[]=).with(:locale, locale)
          get :index, params: {custom_locale: locale}
        end
      end

      context "when using the 'locale' parameter" do
        it 'overwrites the session' do
          expect(session).to receive(:[]=).with(:locale, locale)
          get :index, params: {locale:}
        end
      end
    end

    context "with a 'locale' value in the session" do
      it 'sets this locale' do
        session[:locale] = locale
        # The around block first sets the default language and then the language requested
        expect(I18n).to receive(:locale=).with(I18n.default_locale)
        expect(I18n).to receive(:locale=).with(locale)
        get :index
      end
    end

    context "without a 'locale' value in the session" do
      it 'sets the default locale' do
        expect(session[:locale]).to be_blank
        expect(I18n).to receive(:locale=).with(I18n.default_locale).at_least(:once)
        get :index
      end
    end
  end

  describe 'GET #index' do
    before { get :index }

    expect_http_status(:ok)
    expect_template(:index)
  end
end
