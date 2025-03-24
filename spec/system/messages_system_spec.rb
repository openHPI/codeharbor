# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MessagesController', :js do
  let(:user) { create(:user) }
  let(:password) { attributes_for(:user)[:password] }

  before do
    sign_in_with_js_driver(user, password)
  end

  describe '#index' do
    subject(:view_inbox) { visit(user_messages_path(user)) }

    context 'when receiving a collection invitation' do
      let(:collection_owner) { create(:user) }
      let(:collection) { create(:collection, users: [collection_owner]) }
      let!(:message) { create(:message, recipient: user, sender: collection_owner, action: :collection_shared, attachment: collection) }
      let(:view_shared_link) { view_shared_collection_path(collection, user: collection_owner) }
      let(:save_shared_link) { save_shared_collection_path(collection) }

      it 'shows the message with a link to the collection' do
        view_inbox
        expect(page).to have_link(href: view_shared_link)
        expect(page).to have_link(href: save_shared_link)
      end

      it 'adds the user to the collection when saving the collection' do
        view_inbox
        expect do
          find("[href='#{save_shared_link}'").click
          wait_for_ajax
        end.to change { collection.users.reload.include? user }.from(false).to(true)
      end

      context 'when the collection has been deleted' do
        before { collection.destroy }

        it 'still shows the invitation message' do
          view_inbox
          expect(page).to have_content(message.reload.text)
        end

        it 'does not display links to view or save the collection' do
          view_inbox
          expect(page).to have_no_link(href: view_shared_link)
          expect(page).to have_no_link(href: save_shared_link)
        end
      end
    end

    context 'when receiving a group membership request' do
      let(:group_memberships) { [build(:group_membership, :with_admin, user:), build(:group_membership, :with_applicant, user: sender)] }
      let(:group) { create(:group, group_memberships:) }
      let(:sender) { create(:user) }
      let!(:message) { create(:message, recipient: user, sender:, action: :group_request, attachment: group) }
      let(:grant_access_link) { grant_access_group_path(group, user: sender) }
      let(:deny_access_link) { deny_access_group_path(group, user: sender) }

      it 'shows the message with links to grant or deny the request' do
        view_inbox
        expect(page).to have_link(href: grant_access_link)
        expect(page).to have_link(href: deny_access_link)
      end

      it 'confirms the sender as a group member when clicking the grant access link' do
        view_inbox
        expect do
          find("[href='#{grant_access_link}'").click
          wait_for_ajax
        end.to change { group.reload.confirmed_member? sender }.from(false).to(true)
      end

      context 'when the group has been deleted' do
        before { group.destroy }

        it 'still shows the request message' do
          view_inbox
          expect(page).to have_content(message.reload.text)
        end

        it 'does not display links to grant or deny the request' do
          view_inbox
          expect(page).to have_no_link(href: grant_access_link)
          expect(page).to have_no_link(href: deny_access_link)
        end
      end
    end
  end
end
