# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::NbpWalletController do
  render_views

  let(:connector_api_url) { "#{Settings.omniauth.nbp.enmeshed.connector_url}/api/v2" }

  before do
    stub_request(:get, "#{connector_api_url}/Account/IdentityInfo")
      .to_return(body: file_fixture('enmeshed/get_enmeshed_address.json'))

    stub_request(:get, "#{connector_api_url}/Attributes?content.@type=IdentityAttribute&content.owner=example_enmeshed_address&content.value.@type=DisplayName")
      .to_return(body: file_fixture('enmeshed/no_existing_display_name.json'))

    stub_request(:post, "#{connector_api_url}/Attributes")
      .to_return(body: file_fixture('enmeshed/display_name_created.json'))

    stub_request(:post, "#{connector_api_url}/RelationshipTemplates/Own")
      .to_return(body: file_fixture('enmeshed/relationship_template_created.json'))

    stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
      .to_return(body: file_fixture('enmeshed/valid_relationship_created.json'))

    session[:saml_uid] = 'example_uid'
    session[:omniauth_provider] = 'nbp'
    allow(User).to receive(:omniauth_providers).and_return([:nbp])
  end

  describe 'GET #connect' do
    subject(:get_request) { get :connect }

    context 'when the connector is down' do
      before { stub_request(:get, "#{connector_api_url}/Relationships?status=Pending").to_timeout }

      it 'redirects to the registration page' do
        get_request
        expect(response).to redirect_to(new_user_registration_path)
      end
    end

    context 'without errors' do
      context 'when there is a pending Relationship' do
        it 'redirects to #finalize' do
          get_request
          expect(response).to redirect_to(nbp_wallet_finalize_users_path)
        end
      end

      context 'when there is no pending Relationship' do
        before { session[:saml_uid] = 'example_uid_without_pending_relationships' }

        it 'sets the correct template' do
          get_request
          expect(assigns(:template).truncated_reference).to eq('relationship_template_example_truncated_reference')
        end
      end
    end

    context 'when the display name is cached' do
      before do
        display_name_attribute = Enmeshed::Attribute::Identity.new(type: 'DisplayName', value: 'cached_display_name')
        display_name_attribute.instance_variable_set(:@id, 'cached_id')
        Enmeshed::RelationshipTemplate.instance_variable_set(:@display_name_attribute, display_name_attribute)

        stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
          .to_return(body: file_fixture('enmeshed/no_relationships_yet.json'))
      end

      it 'does not set a new display name id' do
        get_request
        expect(Enmeshed::RelationshipTemplate.display_name_attribute.id).to eq('cached_id')
      end
    end

    context 'when no display name is cached' do
      before do
        Enmeshed::RelationshipTemplate.instance_variable_set(:@display_name_attribute, nil)

        stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
          .to_return(body: file_fixture('enmeshed/no_relationships_yet.json'))
      end

      context 'when a display name exists' do
        before do
          stub_request(:get, "#{connector_api_url}/Attributes?content.@type=IdentityAttribute&content.owner=example_enmeshed_address&content.value.@type=DisplayName")
            .to_return(body: file_fixture('enmeshed/existing_display_name.json'))
        end

        it 'sets the display name id to the existing one' do
          get_request
          expect(Enmeshed::RelationshipTemplate.display_name_attribute.id).to eq('ATT_id_of_existing_display_name')
        end
      end

      context 'when no display name exists' do
        before do
          stub_request(:get, "#{connector_api_url}/Attributes?content.@type=IdentityAttribute&content.owner=example_enmeshed_address&content.value.@type=DisplayName")
            .to_return(body: file_fixture('enmeshed/no_existing_display_name.json'))
        end

        it 'creates a new display name' do
          get_request
          expect(Enmeshed::RelationshipTemplate.display_name_attribute.id).to eq('ATT_id_of_new_display_name')
        end
      end
    end
  end

  describe 'GET #relationship_status' do
    subject(:get_request) { get :relationship_status }

    before { session[:relationship_template_id] = 'RLT_example_id_ABCXY' }

    context 'when the connector is down' do
      before { stub_request(:get, "#{connector_api_url}/Relationships?status=Pending").to_timeout }

      it 'redirects to the connect page' do
        get_request
        expect(response).to redirect_to(nbp_wallet_connect_users_path)
      end
    end

    context 'when no relationship has been created yet' do
      before do
        stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
          .to_return(body: file_fixture('enmeshed/no_relationships_yet.json'))
      end

      it 'returns a json with the waiting status' do
        get_request
        expect(response.parsed_body['status']).to eq 'waiting'
      end
    end

    context 'when the relationship is expired' do
      let(:reject_request_stub) { stub_request(:put, "#{connector_api_url}/Relationships/RELoi9IL4adMbj92K8dn/Changes/RCHNFJ9JD2LayPxn79nO/Reject") }

      before do
        stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
          .to_return(body: file_fixture('enmeshed/relationship_expired.json'))

        reject_request_stub
      end

      it 'returns a json with the waiting status' do
        get_request
        expect(response.parsed_body['status']).to eq 'waiting'
      end

      it 'tries to reject the RelationshipChange' do
        get_request
        expect(reject_request_stub).to have_been_requested
      end
    end

    context 'when the relationship is valid' do
      let(:reject_request_stub) { stub_request(:put, "#{connector_api_url}/Relationships/RELoi9IL4adMbj92K8dn/Changes/RCHNFJ9JD2LayPxn79nO/Reject") }

      before do
        stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
          .to_return(body: file_fixture('enmeshed/valid_relationship_created.json'))

        reject_request_stub
      end

      it 'returns a json with the ready status' do
        get_request
        expect(response.parsed_body['status']).to eq 'ready'
      end

      it 'does not reject the RelationshipChange' do
        get_request
        expect(reject_request_stub).not_to have_been_requested
      end
    end
  end

  describe 'GET #qr_code' do
    subject(:get_request) { get :qr_code, params: {truncated_reference:} }

    let(:truncated_reference) { 'example_truncated_reference' }
    let(:qr_code) { RQRCode::QRCode.new("nmshd://tr##{truncated_reference}").as_png(border_modules: 0) }

    it 'returns a png image' do
      get_request
      expect(response.content_type).to eq 'image/png'
    end

    it 'initializes a RelationshipTemplate' do
      expect(Enmeshed::RelationshipTemplate).to receive(:new).with(truncated_reference:, skip_fetch: true).and_call_original
      get_request
    end

    it 'sends the qr code' do
      get_request
      expect(response.body).to eq qr_code.to_s
    end
  end

  describe 'GET #finalize' do
    subject(:get_request) { get :finalize }

    let(:reject_request_stub) { stub_request(:put, "#{connector_api_url}/Relationships/RELoi9IL4adMbj92K8dn/Changes/RCHNFJ9JD2LayPxn79nO/Reject") }
    let(:accept_request_stub) { stub_request(:put, "#{connector_api_url}/Relationships/RELoi9IL4adMbj92K8dn/Changes/RCHNFJ9JD2LayPxn79nO/Accept") }

    before do
      session[:relationship_template_id] = 'RLT_example_id_ABCXY'

      stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
        .to_return(body: file_fixture('enmeshed/valid_relationship_created.json'))
      stub_request(:get, "#{connector_api_url}/Relationships")
        .to_return(body: file_fixture('enmeshed/valid_relationship_created.json'))

      accept_request_stub
      reject_request_stub
    end

    context 'when the connector is down' do
      before { stub_request(:get, "#{connector_api_url}/Relationships?status=Pending").to_timeout }

      it 'redirects to the connect page' do
        get_request
        expect(response).to redirect_to(nbp_wallet_connect_users_path)
      end
    end

    context 'without errors' do
      it 'accepts the RelationshipChange' do
        get_request
        expect(accept_request_stub).to have_been_requested
      end

      it 'creates a user' do
        expect { get_request }.to change(User, :count).by(1)
      end

      it 'creates two UserIdentities' do
        expect { get_request }.to change(UserIdentity, :count).by(2)
      end

      it 'sends a confirmation mail' do
        expect { get_request }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it 'does not create a confirmed user' do
        get_request
        expect(User.order(:created_at).last).not_to be_confirmed
      end
    end

    context 'when the user cannot be created' do
      before do
        create(:user, email: 'already_taken@problem.eu')

        stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
          .to_return(body: file_fixture('enmeshed/relationship_impossible_attributes.json'))
      end

      it 'rejects the RelationshipChange' do
        get_request
        expect(reject_request_stub).to have_been_requested
      end

      it 'does not create a user' do
        expect { get_request }.not_to change(User, :count)
      end

      it 'creates no UserIdentities' do
        expect { get_request }.not_to change(UserIdentity, :count)
      end

      it 'redirects to the connect page' do
        get_request
        expect(response).to redirect_to nbp_wallet_connect_users_path
      end

      it 'does not send a confirmation mail' do
        expect { get_request }.not_to change(ActionMailer::Base, :deliveries)
      end
    end

    context 'when the RelationshipChange cannot be accepted' do
      before { accept_request_stub.to_return(status: 500) }

      it 'does not create a user' do
        expect { get_request }.not_to change(User, :count)
      end

      it 'creates no UserIdentities' do
        expect { get_request }.not_to change(UserIdentity, :count)
      end

      it 'redirects to the connect page' do
        get_request
        expect(response).to redirect_to nbp_wallet_connect_users_path
      end

      it 'does not send a confirmation mail' do
        expect { get_request }.not_to change(ActionMailer::Base, :deliveries)
      end

      context 'when the RelationshipChange cannot be rejected either' do
        before { reject_request_stub.to_timeout }

        it 'does not create a user' do
          expect { get_request }.not_to change(User, :count)
        end

        it 'creates no UserIdentities' do
          expect { get_request }.not_to change(UserIdentity, :count)
        end

        it 'redirects to the connect page' do
          get_request
          expect(response).to redirect_to nbp_wallet_connect_users_path
        end

        it 'does not send a confirmation mail' do
          expect { get_request }.not_to change(ActionMailer::Base, :deliveries)
        end
      end
    end

    context 'when an invalid role is provided' do
      before do
        stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
          .to_return(body: file_fixture('enmeshed/invalid_role_relationship.json'))
      end

      it 'does not create a user' do
        expect { get_request }.not_to change(User, :count)
      end

      it 'redirects to the connect page' do
        get_request
        expect(response).to redirect_to nbp_wallet_connect_users_path
      end
    end

    context 'when an attribute is missing' do
      before do
        stub_request(:get, "#{connector_api_url}/Relationships?status=Pending")
          .to_return(body: file_fixture('enmeshed/missing_attribute_relationship.json'))
      end

      it 'does not create a user' do
        expect { get_request }.not_to change(User, :count)
      end

      it 'redirects to the connect page' do
        get_request
        expect(response).to redirect_to nbp_wallet_connect_users_path
      end
    end
  end
end
