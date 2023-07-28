# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bridges::Lom::TasksController do
  render_views

  let(:user) { create(:user) }
  let(:programming_language) { create(:programming_language) }
  let(:license) { create(:license) }
  let(:parent_uuid) { create(:task).uuid }
  let(:public_task) { create(:task, :with_content, user:, parent_uuid:, programming_language:, license:, access_level: :public) }
  let(:private_task) { create(:task, :with_content, user:, parent_uuid:, programming_language:, license:, access_level: :private) }

  describe 'GET #show' do
    subject(:get_request) { get :show, params: {id: task.to_param} }

    shared_examples 'is a valid LOM reponse' do
      it 'returns HTTP OK' do
        expect(response).to have_http_status :ok
      end

      it 'returns valid LOM xml' do
        get_request
        schema = Nokogiri::XML::Schema(File.read(Bridges::Lom::TasksController::OML_SCHEMA_PATH))
        expect(schema.validate(Nokogiri::XML(response.body))).to be_empty
      end
    end

    context 'without being signed in' do
      let(:task) { public_task }

      context 'when task is public' do
        let(:task) { public_task }

        include_examples 'is a valid LOM reponse'
      end

      context 'when task is private' do
        let(:task) { private_task }

        it 'returns HTTP forbidden' do
          get_request
          expect(response).to have_http_status :forbidden
        end
      end
    end

    context 'when signed in as owner of the task' do
      before { sign_in user }

      context 'when task is public' do
        let(:task) { public_task }

        include_examples 'is a valid LOM reponse'
      end

      context 'when task is private' do
        let(:task) { private_task }

        include_examples 'is a valid LOM reponse'
      end
    end

    context 'when signed in user is not owner of the task' do
      before { sign_in create(:user) }

      context 'when task is public' do
        let(:task) { public_task }

        include_examples 'is a valid LOM reponse'
      end

      context 'when task is private' do
        let(:task) { private_task }

        it 'returns HTTP forbidden' do
          get_request
          expect(response).to have_http_status :forbidden
        end
      end
    end

    context 'when signed in as a group member' do
      let(:group_member) { create(:user) }
      let(:task) { private_task }
      let(:group_memberships) { [build(:group_membership, :with_admin), build(:group_membership, user: group_member)] }

      before do
        create(:group, group_memberships:, tasks: [task])
        sign_in group_member
      end

      include_examples 'is a valid LOM reponse'
    end
  end
end
