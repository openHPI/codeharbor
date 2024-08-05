# frozen_string_literal: true

module ProformaService
  class HandleExportConfirm < ServiceBase
    def initialize(user:, task:, push_type:, account_link:)
      super()
      @user = user
      @task = task
      @push_type = push_type
      @account_link = account_link
    end

    def execute
      if @push_type == 'create_new'
        @task = @task.initialize_derivate(@user)
        @task.save!
        @task.reload
      end

      zip_stream = ProformaService::ExportTask.call(task: @task,
        options: {description_format: 'md', version: @account_link.proforma_version || ProformaXML::SCHEMA_VERSION_LATEST})
      error = TaskService::PushExternal.call(zip: zip_stream, account_link: @account_link)

      [@task, error]
    end
  end
end
