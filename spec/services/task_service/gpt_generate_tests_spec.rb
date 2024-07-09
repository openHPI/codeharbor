# spec/services/task_service/gpt_generate_tests_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskService::GptGenerateTests do
  describe '.new' do
    subject(:gpt_generate_tests_service) { described_class.new(task:, openai_api_key:) }

    let(:programming_language) { build(:programming_language, :ruby) }
    let(:task) { build(:task, description: 'Sample Task', programming_language:) }
    let(:openai_api_key) { 'valid_api_key' }
    let(:mock_models) { instance_double(OpenAI::Models, list: {'data' => [{'id' => 'model-id'}]}) }

    before do
      allow(OpenAI::Client).to receive(:new).and_return(instance_double(OpenAI::Client, models: mock_models))
    end

    it 'assigns task' do
      expect(gpt_generate_tests_service.instance_variable_get(:@task)).to be task
    end

    it 'assigns openai_api_key' do
      expect(gpt_generate_tests_service.instance_variable_get(:@openai_api_key)).to eq openai_api_key
    end

    context 'when language is missing' do
      let(:task) { build(:task, description: 'Sample Task', programming_language: nil) }

      it 'raises MissingLanguageError' do
        expect { gpt_generate_tests_service }.to raise_error(Gpt::MissingLanguageError)
      end
    end

    context 'when API key is missing' do
      let(:openai_api_key) { nil }

      it 'raises InvalidApiKeyError' do
        expect { gpt_generate_tests_service }.to raise_error(Gpt::InvalidApiKeyError)
      end
    end

    context 'when API key is invalid' do
      let(:openai_api_key) { 'invalid_api_key' }
      let(:mock_models_invalid) { instance_double(OpenAI::Models) }

      before do
        allow(mock_models_invalid).to receive(:list).and_raise(Faraday::UnauthorizedError)
        allow(OpenAI::Client).to receive(:new).and_return(instance_double(OpenAI::Client, models: mock_models_invalid))
      end

      it 'raises InvalidApiKeyError' do
        expect { gpt_generate_tests_service }.to raise_error(Gpt::InvalidApiKeyError)
      end
    end
  end

  describe '#call' do
    subject(:gpt_generate_tests) { described_class.call(task:, openai_api_key:) }

    let(:programming_language) { create(:programming_language, :python) }
    let(:task) { create(:task, description: 'Create a Python script.', programming_language:) }
    let(:openai_api_key) { 'valid_api_key' }
    let(:mock_client) { instance_double(OpenAI::Client) }
    let(:mock_models) { instance_double(OpenAI::Models, list: {'data' => [{'id' => 'text-davinci-002'}]}) }

    before do
      allow(OpenAI::Client).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:models).and_return(mock_models)
    end

    context 'when the response includes valid code blocks' do
      before do
        allow(mock_client).to receive(:chat).and_return('choices' => [{'message' => {'content' => "```Python\ndef test_script():\n  assert true```"}}])
        gpt_generate_tests
      end

      it 'creates a test file related to the task' do
        test_file = task.reload.tests.last.files.first
        expect(test_file).to have_attributes(
          content: "def test_script():\n  assert true",
          name: 'test.py'
        )
      end

      it 'creates a test instance related to the task' do
        test = task.reload.tests.last
        expect(test).to have_attributes(title: I18n.t('tests.model.generated_test'))
      end
    end

    context 'when the response does not contain backticks' do
      before do
        allow(mock_client).to receive(:chat).and_return({'choices' => [{'message' => {'content' => 'Python script should assert true without any code block.'}}]})
      end

      it 'raises InvalidTaskDescription' do
        expect { gpt_generate_tests }.to raise_error(Gpt::InvalidTaskDescription)
      end
    end
  end
end
