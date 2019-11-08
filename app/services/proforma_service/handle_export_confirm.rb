# frozen_string_literal: true

module ProformaService
  class HandleExportConfirm < ServiceBase
    def initialize(user:, exercise:, push_type:, account_link_id:)
      @user = user
      @exercise = exercise
      @push_type = push_type
      @account_link_id = account_link_id
    end

    def execute
      if @push_type == 'create_new'
        @exercise = @exercise.initialize_derivate(@user)
        @exercise.save!
        @exercise.reload
      end

      account_link = AccountLink.find(@account_link_id)
      zip = ProformaService::ExportTask.call(exercise: @exercise)
      error = ExerciseService::PushExternal.call(zip: zip, account_link: account_link)

      [@exercise, error]
    end
  end
end
