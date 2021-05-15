# frozen_string_literal: true

module ProformaService
  class TaskFromCachedFile < ServiceBase
    def initialize(import_id:, subfile_id:, import_type:)
      @import_id = import_id
      @subfile_id = subfile_id
      @import_type = import_type
    end

    def execute
      import_cache_file = ImportFileCache.find(@import_id)
      import_tasks = ProformaService::ConvertZipToProformaTasks.call(zip_file: import_cache_file.zip_file)
      subfile = import_cache_file.data[@subfile_id]
      task = import_tasks.find { |task_hash| task_hash[:path] == subfile.with_indifferent_access[:path] }[:task]
      task.tap { |t| t.uuid = nil if @import_type == 'create_new' }
    end
  end
end
