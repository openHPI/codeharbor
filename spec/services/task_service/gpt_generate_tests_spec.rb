# spec/services/task_service/gpt_generate_tests_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskService::GptGenerateTests do
  let(:openai_api_key) { 'valid_api_key' }
  let(:openai_client) { OpenAI::Client.new(access_token: openai_api_key) }
  let(:openai_models) { instance_double(OpenAI::Models, list: {'data' => [{'id' => 'model-id'}]}) }

  let(:programming_language) { create(:programming_language, :python) }
  let(:task) { create(:task, description: 'Create a Python script.', programming_language:) }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
    allow(openai_client).to receive(:models).and_return(openai_models)
  end

  describe '.new' do
    subject(:gpt_generate_tests_service) { described_class.new(task:, openai_api_key:) }

    it 'assigns the task' do
      expect(gpt_generate_tests_service.instance_variable_get(:@task)).to be task
    end

    it 'assigns the client for OpenAI' do
      expect(gpt_generate_tests_service.instance_variable_get(:@client)).to be openai_client
    end

    it 'stores the OpenAI API key in the client' do
      expect(gpt_generate_tests_service.instance_variable_get(:@client).access_token).to eq openai_api_key
    end

    context 'when language is missing' do
      let(:programming_language) { nil }

      it 'raises MissingLanguageError' do
        expect { gpt_generate_tests_service }.to raise_error(Gpt::Error::MissingLanguage)
      end
    end

    context 'when API key is missing' do
      let(:openai_api_key) { nil }

      it 'raises InvalidApiKeyError' do
        expect { gpt_generate_tests_service }.to raise_error(Gpt::Error::InvalidApiKey)
      end
    end

    context 'when API key is invalid' do
      let(:openai_api_key) { 'invalid_api_key' }

      before do
        allow(openai_models).to receive(:list).and_raise(Faraday::UnauthorizedError)
      end

      it 'raises InvalidApiKeyError' do
        expect { gpt_generate_tests_service }.to raise_error(Gpt::Error::InvalidApiKey)
      end
    end

    context 'when OpenAI is not responding' do
      before do
        allow(openai_models).to receive(:list).and_raise(Faraday::Error)
      end

      it 'raises InternalServerError' do
        expect { gpt_generate_tests_service }.to raise_error(Gpt::Error::InternalServerError)
      end
    end

    context 'when the network connection is broken' do
      before do
        allow(openai_models).to receive(:list).and_raise(EOFError)
      end

      it 'raises an error' do
        expect { gpt_generate_tests_service }.to raise_error(Gpt::Error)
      end
    end
  end

  describe '#call' do
    subject(:gpt_generate_tests) { described_class.call(task:, openai_api_key:) }

    let(:chat_response) { {'choices' => [{'message' => {'content' => "```Python\ndef test_script():\n  assert true```"}}]} }

    before do
      allow(openai_client).to receive(:chat).and_return(chat_response)
    end

    context 'when the response includes valid code blocks' do
      before do
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
      let(:chat_response) { {'choices' => [{'message' => {'content' => 'Python script should assert true without any code block.'}}]} }

      it 'raises InvalidTaskDescription' do
        expect { gpt_generate_tests }.to raise_error(Gpt::Error::InvalidTaskDescription)
      end
    end

    context 'when OpenAI is not responding' do
      before do
        allow(openai_client).to receive(:chat).and_raise(Faraday::Error)
      end

      it 'raises InternalServerError' do
        expect { gpt_generate_tests }.to raise_error(Gpt::Error::InternalServerError)
      end
    end

    context 'when the network connection is broken' do
      before do
        allow(openai_client).to receive(:chat).and_raise(EOFError)
      end

      it 'raises an error' do
        expect { gpt_generate_tests }.to raise_error(Gpt::Error)
      end
    end
  end
end
