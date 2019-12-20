# frozen_string_literal: true

module ProformaService
  class ImportTask < ServiceBase
    def initialize(task:, user:)
      @task = task
      @user = user
    end

    def execute
      exercise = ConvertTaskToExercise.call(task: @task, user: @user, exercise: base_exercise)
      ActiveRecord::Base.transaction do
        exercise.save_old_version if exercise.persisted?
        exercise.save!
      end

      exercise
    end

    private

    def base_exercise
      exercise = Exercise.unscoped.find_by(uuid: @task.uuid)
      if exercise
        return exercise if exercise.updatable_by?(@user)

        return Exercise.new(uuid: SecureRandom.uuid)
      end

      Exercise.new(uuid: @task.uuid || SecureRandom.uuid)
    end
  end
end
