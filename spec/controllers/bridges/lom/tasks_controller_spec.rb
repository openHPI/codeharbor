# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bridges::Lom::TasksController do
  render_views

  let(:user) { create(:user) }
  let(:programming_language) { create(:programming_language, :ruby) }
  let(:license) { create(:license) }
  let(:parent_uuid) { create(:task).uuid }
  let(:task) { create(:task, :with_content, :with_labels, user:, parent_uuid:, programming_language:, license:) }

  describe 'GET #show' do
    subject(:get_request) { get :show, params: {id: task.to_param} }

    shared_examples 'is a valid LOM response' do
      it 'returns HTTP OK' do
        expect(response).to have_http_status :ok
      end

      it 'returns valid LOM xml' do
        get_request
        schema = Nokogiri::XML::Schema(File.read(Bridges::Lom::TasksController::OML_SCHEMA_PATH))
        expect(schema.validate(Nokogiri::XML(response.body))).to be_empty
      end
    end

    context 'when allowed to access the LOM' do
      before { allow(task).to receive(:lom_showable_by?).and_return(true) }

      it 'returns valid LOM xml' do
        get_request
        schema = Nokogiri::XML::Schema(File.read(Bridges::Lom::TasksController::OML_SCHEMA_PATH))
        expect(schema.validate(Nokogiri::XML(response.body))).to be_empty
      end
    end

    context 'when not allowed to access the LOM' do
      before { allow(task).to receive(:lom_showable_by?).and_return(false) }

      it 'returns HTTP forbidden' do
        get_request
        expect(response).to have_http_status :forbidden
      end
    end

    context 'with additional details' do
      before { allow(task).to receive(:lom_showable_by?).and_return(true) }

      context 'when no license is specified' do
        let(:license) { nil }

        include_examples 'is a valid LOM response'
      end

      context 'when ratings are available' do
        before { create(:rating, task:, user:) }

        include_examples 'is a valid LOM response'
      end

      context 'when comments are available' do
        before { create(:comment, task:, user:) }

        include_examples 'is a valid LOM response'
      end
    end
  end
end
