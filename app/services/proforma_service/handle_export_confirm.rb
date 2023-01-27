# frozen_string_literal: true

module ProformaService
  class HandleExportConfirm < ServiceBase
    def initialize(user:, task:, push_type:, account_link_id:)
      super()
      @user = user
      @task = task
      @push_type = push_type
      @account_link_id = account_link_id
    end

    def execute
      if @push_type == 'create_new'
        @task = @task.initialize_derivate(@user)
        @task.save!
        @task.reload
      end

      account_link = AccountLink.find(@account_link_id)
      zip_stream = ProformaService::ExportTask.call(task: @task, options: {description_format: 'md'})
      error = TaskService::PushExternal.call(zip: zip_stream, account_link:)

      [@task, error]
    end
  end
end
