# frozen_string_literal: true

module TaskService
  class GptGenerateTests < ServiceBase
    def initialize(task:, openai_api_key:)
      super()
      raise Gpt::Error::MissingLanguage if task.programming_language&.language.blank?

      @task = task
      @client = self.class.new_client! openai_api_key
    end

    def execute
      file_name = "test#{@task.programming_language.file_extension}"

      test_file = TaskFile.new(content: gpt_response, name: file_name, used_by_grader: true, visible: false, xml_id: SecureRandom.uuid)
      test = Test.new(task: @task, title: I18n.t('tests.model.generated_test'), xml_id: SecureRandom.uuid, files: [test_file])

      @task.tests << test
    end

    def self.new_client!(access_token)
      raise Gpt::Error::InvalidApiKey if access_token.blank?

      client = OpenAI::Client.new(access_token:)
      validate! client
      client
    end

    private

    def gpt_response # rubocop:disable Metrics/AbcSize
      # train client with some prompts
      messages = training_prompts.map do |prompt|
        {role: 'system', content: prompt}
      end

      # send user message
      messages << {role: 'user', content: @task.description}

      # create gpt client
      response = @client.chat(
        parameters: {
          model: Settings.open_ai.model,
          messages:,
          temperature: 0.7, # Lower values insure reproducibility
        }
      )

      # parse out the response
      raw_response = response.dig('choices', 0, 'message', 'content')

      # check for ``` in the response and extract the text between the first set
      raise Gpt::Error::InvalidTaskDescription unless raw_response.include?('```')

      raw_response[/```(.*?)```/m, 1].lines[1..]&.join&.strip
    rescue Faraday::UnauthorizedError => e
      raise Gpt::Error::UnauthorizedError.new("Unauthorized access to OpenAI: #{e.message}")
    rescue Faraday::Error => e
      raise Gpt::Error::InternalServerError.new("Could not communicate with OpenAI due to #{e.inspect}")
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, SocketError, EOFError => e
      raise Gpt::Error.new(e)
    end

    def training_prompts
      [
        <<~PROMPT,
          Given a description of a programming task, you are tasked with creating a comprehensive set \
          of unit tests that thoroughly cover all potential scenarios, including edge cases, related to this task. \
          Your output should be a single test file written in the specified programming language, denoted as #{@task.programming_language&.language}. \
          The unit tests should be designed to validate the functionality and reliability of the implementation based \
          on the task description provided. If the provided description is not clear or if it is not a programming task, \
          provide a brief explanation of what is missing and request a better task description. Otherwise, only provide \
          the test file and no additional text.
        PROMPT
      ]
    end

    def self.validate!(client)
      response = client.models.list
      raise Gpt::Error::InvalidApiKey unless response['data']
    rescue Faraday::UnauthorizedError, OpenAI::Error
      raise Gpt::Error::InvalidApiKey
    rescue Faraday::Error => e
      raise Gpt::Error::InternalServerError.new("Could not communicate with OpenAI due to #{e.inspect}")
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, SocketError, EOFError
      raise Gpt::Error
    end
    private_class_method :validate!
  end
end
