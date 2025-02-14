# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::NBPWallet::Finalize' do
  subject(:finalize_request) { get '/users/nbp_wallet/finalize' }

  let(:uid) { 'example-uid' }
  let(:session_params) { {saml_uid: uid, omniauth_provider: 'nbp'} }
  let(:relationship) { instance_double(Enmeshed::Relationship) }

  before do
    set_session(session_params)
  end

  context 'without any errors' do
    before do
      allow(Enmeshed::Relationship).to receive(:pending_for).with(uid).and_return(relationship)
      allow(relationship).to receive_messages(peer: 'id1EvvJ68x6wdHBwYrFTR31XtALHko9fnbyp', accept!: true,
        userdata: {email: 'john.oliver@example103.org', first_name: 'john', last_name: 'oliver', status_group: :learner})
    end

    it 'creates a user' do
      expect { finalize_request }.to change(User, :count).by(1)
    end

    it 'creates two UserIdentities' do
      expect { finalize_request }.to change(UserIdentity, :count).by(2)
    end

    it 'accepts the Relationship' do
      expect(relationship).to receive(:accept!)
      finalize_request
    end

    it 'sends a confirmation mail' do
      expect { finalize_request }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it 'does not create a confirmed user' do
      finalize_request
      expect(User.order(:created_at).last).not_to be_confirmed
    end

    it 'clears the session' do
      finalize_request
      expect(session.keys).to contain_exactly('flash')
    end

    it 'asks the user to verify the email address' do
      finalize_request
      expect(response).to redirect_to home_index_path
      expect(flash[:notice]).to include I18n.t('devise.registrations.signed_up_but_unconfirmed')
    end
  end

  context 'with errors' do
    shared_examples 'a handled erroneous request' do |error_message|
      it 'does not create a user' do
        expect { finalize_request }.not_to change(User, :count)
      end

      it 'creates no UserIdentities' do
        expect { finalize_request }.not_to change(UserIdentity, :count)
      end

      it 'redirects to the connect page' do
        finalize_request
        expect(response).to redirect_to nbp_wallet_connect_users_path
      end

      it 'displays an error message' do
        finalize_request
        expect(flash[:alert]).to eq error_message
      end

      it 'does not send a confirmation mail' do
        expect { finalize_request }.not_to change(ActionMailer::Base, :deliveries)
      end

      it 'does not clear the session' do
        finalize_request
        expect(session.keys).to include('flash', 'omniauth_provider', 'saml_uid', 'session_id')
      end
    end

    shared_examples 'a documented erroneous request' do |error|
      it 'passes the error reason to Sentry' do
        expect(Sentry).to receive(:capture_exception) do |e|
          expect(e).to be_a error
        end
        finalize_request
      end
    end

    context 'without the session' do
      let(:session_params) { {} }

      before do
        finalize_request
      end

      it_behaves_like 'an unauthorized request'
    end

    context 'when the connector is down' do
      before { allow(Enmeshed::Relationship).to receive(:pending_for).with(uid).and_raise(Faraday::ConnectionFailed) }

      it 'redirects to the connect page' do
        finalize_request
        expect(response).to redirect_to(nbp_wallet_connect_users_path)
      end
    end

    context 'when an attribute is missing' do
      before do
        allow(Enmeshed::Relationship).to receive(:pending_for).with(uid).and_return(relationship)
        allow(relationship).to receive_messages(
          userdata: {first_name: 'john', last_name: 'oliver', status_group: :learner},
          peer: 'id1EvvJ68x6wdHBwYrFTR31XtALHko9fnbyp',
          reject!: true
        )
      end

      it_behaves_like 'a handled erroneous request', "Could not create User: Email can't be blank"
    end

    context 'with an invalid status group' do
      before do
        allow(Enmeshed::Relationship).to receive(:pending_for).with(uid).and_return(relationship)
        allow(relationship).to receive_messages(reject!: true, peer: 'id1EvvJ68x6wdHBwYrFTR31XtALHko9fnbyp', userdata: {
          email: 'john.oliver@example103.org',
          first_name: 'john',
          last_name: 'oliver',
          status_group: nil,
        })
      end

      it_behaves_like 'a handled erroneous request', 'Could not create User: Status Group is unknown. ' \
                                                     'Please select either "Teacher" or "Student" as your role.'
    end

    context 'with a blank name' do
      before do
        allow(Enmeshed::Relationship).to receive(:pending_for).with(uid).and_return(relationship)
        allow(relationship).to receive_messages(
          userdata: {email: 'john.oliver@example103.org', first_name: ' ', last_name: 'oliver', status_group: :learner},
          peer: 'id1EvvJ68x6wdHBwYrFTR31XtALHko9fnbyp',
          reject!: true
        )
      end

      it_behaves_like 'a handled erroneous request', "Could not create User: First Name can't be blank"
    end

    context 'when email address already has been taken' do
      before do
        create(:user, email: 'john.oliver@example103.org')
        allow(Enmeshed::Relationship).to receive(:pending_for).with(uid).and_return(relationship)
        allow(relationship).to receive_messages(
          userdata: {email: 'john.oliver@example103.org', first_name: 'john', last_name: 'oliver', status_group: :learner},
          peer: 'id1EvvJ68x6wdHBwYrFTR31XtALHko9fnbyp',
          reject!: true
        )
      end

      it_behaves_like 'a handled erroneous request', 'Could not create User: Email has already been taken'
    end

    context 'when the RelationshipChange cannot be accepted' do
      before do
        allow(Enmeshed::Relationship).to receive(:pending_for).with(uid).and_return(relationship)
        allow(relationship).to receive_messages(
          userdata: {email: 'john.oliver@example103.org', first_name: 'john', last_name: 'oliver', status_group: :learner},
          peer: 'id1EvvJ68x6wdHBwYrFTR31XtALHko9fnbyp',
          accept!: false,
          reject!: true
        )
      end

      it_behaves_like 'a handled erroneous request', I18n.t('common.errors.generic')

      it 'rejects the Relationship' do
        expect(relationship).to receive(:reject!)
        finalize_request
      end

      context 'when the RelationshipChange cannot be rejected either' do
        before { allow(relationship).to receive(:reject!).and_raise(Faraday::ConnectionFailed) }

        it_behaves_like 'a handled erroneous request', I18n.t('common.errors.generic')
        it_behaves_like 'a documented erroneous request', Faraday::ConnectionFailed

        it 'does not create a user' do
          expect { finalize_request }.not_to change(User, :count)
        end

        it 'creates no UserIdentities' do
          expect { finalize_request }.not_to change(UserIdentity, :count)
        end

        it 'does not try to reject the Relationship again' do
          expect(relationship).to receive(:reject!).once
          finalize_request
        end
      end
    end
  end
end
