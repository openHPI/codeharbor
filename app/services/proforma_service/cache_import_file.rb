# frozen_string_literal: true

module ProformaService
  class CacheImportFile < ServiceBase
    def initialize(user:, zip_file:)
      super()
      @user = user
      @zip_file = zip_file
    end

    def execute
      data = {}
      ActiveRecord::Base.transaction do
        import_file = ImportFileCache.create!(user: @user, zip_file: @zip_file)
        ProformaService::ConvertZipToProformaTasks.call(zip_file: @zip_file).each do |proforma_task|
          task = Task.find_by(uuid: proforma_task[:uuid])

          data[SecureRandom.uuid] = file_data_hash(task, import_file, proforma_task)
        end
        import_file.update!(data:)
      end
      data
    end

    private

    def file_data_hash(task, import_file, proforma_task)
      {path: proforma_task[:path],
       exists: task.present?,
       updatable: task.present? && Pundit.policy(@user, task).manage?,
       import_id: import_file.id,
       task_uuid: proforma_task[:uuid]}
    end
  end
end
