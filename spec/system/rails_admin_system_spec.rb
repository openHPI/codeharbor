# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RailsAdmin' do
  let(:user) { create(role) }
  let(:password) { attributes_for(role)[:password] }

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
