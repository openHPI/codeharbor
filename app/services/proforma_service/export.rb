# frozen_string_literal: true

module ProformaService
  class Export < ServiceBase
    def initialize(exercise: nil)
      @exercise = exercise
    end

    def execute
      create_task
      exporter = Proforma::Exporter.new(@task)
      exporter.perform
    end

    def create_task
      @task = Proforma::Task.new(
        title: @exercise.title,
        description: @exercise.descriptions.first.text,
        internal_description: @exercise.instruction,
        proglang: proglang,
        # files: '',
        # tests: '',
        uuid: @exercise.uuid,
        parent_uuid: @exercise.clone_relations.first&.origin&.uuid,
        language: @exercise.descriptions.first.language
        # model_solutions: ''
      )
    end

    def proglang
      {name: @exercise.execution_environment.language, version: @exercise.execution_environment.version}
    end
  end
end
