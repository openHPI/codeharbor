# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bridges::Lom::TasksController do
  render_views

  let(:user) { create(:user) }
  let(:programming_language) { create(:programming_language, :ruby) }
  let(:license) { create(:license) }
  let(:parent_uuid) { create(:task).uuid }
  let(:access_level) { :public }
  let(:task) { create(:task, :with_content, :with_labels, user:, parent_uuid:, programming_language:, license:, access_level:) }

  describe 'GET #show' do
    subject(:get_request) { get :show, params: {id: task.to_param} }

    shared_examples 'is a valid LOM response' do
      it 'returns HTTP OK' do
        expect(response).to have_http_status :ok
      end

      it 'returns valid LOM xml' do
        get_request
        schema = Nokogiri::XML::Schema(File.open(Bridges::Lom::TasksController::OML_SCHEMA_PATH))
        expect(schema.validate(Nokogiri::XML(response.body))).to be_empty
      end
    end

    before { allow(Task).to receive(:find).with(task.id.to_s).and_return(task) }

    context 'when allowed to access the LOM' do
      it_behaves_like 'is a valid LOM response'
    end

    context 'when not allowed to access the LOM' do
      let(:access_level) { :private }

      it 'returns HTTP forbidden' do
        get_request
        expect(response).to have_http_status :forbidden
      end
    end

    context 'with a description in Markdown' do
      let(:description_markdown) { '# Description' }
      let(:description_html) { CGI.escapeHTML '<h1>Description</h1>' }

      before { task.update(description: description_markdown) }

      it 'returns the description in HTML' do
        get_request
        expect(response.body).to include description_html
      end
    end

    context 'with additional details' do
      context 'when no license is specified' do
        let(:license) { nil }

        it_behaves_like 'is a valid LOM response'
      end

      context 'when ratings are available' do
        before { create(:rating, task:, user:) }

        it_behaves_like 'is a valid LOM response'
      end

      context 'when comments are available' do
        before { create(:comment, task:, user:) }

        it_behaves_like 'is a valid LOM response'
      end
    end
  end
end
