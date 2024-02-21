# frozen_string_literal: true

module TaskService
  class GptGenerateTests < ServiceBase
    def initialize(task:)
      super()
      @task = task
      @message = task.description
      @language = @task.programming_language.language || 'Python'
    end

    def execute
      file_content = gpt_response
      test_file = TaskFile.new(content: file_content, name: 'test.py', used_by_grader: true, visible: false, xml_id: SecureRandom.uuid)
      testing_framework = TestingFramework.find_or_initialize_by(name: 'Pytest', version: 6)
      test = Test.new(task: @task, title: 'AI-generated Test', xml_id: SecureRandom.uuid, files: [test_file], testing_framework:)
      @task.tests << test
      @task.save!
    end

    def gpt_response
      # train client with some prompts
      messages = training_prompts.map do |prompt|
        {role: 'system', content: prompt}
      end

      # send user message
      messages << {role: 'user', content: @message}

      # create gpt client
      response = client.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages:,
          temperature: 0.7, # Lower values insure reproducibility
        }
      )

      # parse out the response
      response.dig('choices', 0, 'message', 'content')
    end

    private

    def client
      @client ||= OpenAI::Client.new
    end

    def training_prompts
      [
        <<~PROMPT,
          Given a description of a programming task, you are tasked with creating a comprehensive set \
          of unit tests that thoroughly cover all potential scenarios, including edge cases, related to this task. \
          Your output should be a single test file written in the specified programming language, denoted as #{@language}. \
          The unit tests should be designed to validate the functionality and reliability of the implementation based \
          on the task description provided. if the provided description is not clear or if it is not a programming task, \
          provide a brief explanation of what is missing and request a better task description. otherwise, only provide \
          the test file and no additional text.
        PROMPT
      ]
    end
  end
end
