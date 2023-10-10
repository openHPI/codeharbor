# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RailsAdmin' do
  let(:user) { create(role) }
  let(:password) { attributes_for(role)[:password] }

  before do
    # RailsAdmin will automatically eager load all models (and some further classes).
    # Since this eager loading is not done as expected, the OmniAuth strategies
    # dynamically configuring themselves with an URL will fail and raise an error.
    # To prevent this, we remove the OmniAuth constant from the global namespace,
    # so that the strategies are not loaded and the error is not raised.
    Object.send(:remove_const, :OmniAuth) if defined?(OmniAuth)
  end

  context 'when signed out' do
    it 'redirects to the root page' do
      visit(rails_admin.dashboard_path)
      expect(page).to have_current_path root_path, ignore_query: true
    end
  end

  context 'when signed in' do
    before { sign_in(user, password) }

    context 'with a regular user account' do
      let(:role) { :user }

      it 'redirects to the root page' do
        visit(rails_admin.dashboard_path)
        expect(page).to have_current_path root_path, ignore_query: true
      end
    end

    context 'with an administrator account' do
      let(:role) { :admin }

      it 'grants access to the dashboard' do
        visit(rails_admin.dashboard_path)
        expect(page).to have_current_path rails_admin.dashboard_path, ignore_query: true
      end
    end
  end
end
