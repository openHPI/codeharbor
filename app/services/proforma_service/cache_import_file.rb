# frozen_string_literal: true

module ProformaService
  class CacheImportFile < ServiceBase
    def initialize(user:, zip_file:)
      @user = user
      @zip_file = zip_file
    end

    def execute
      data = {}
      ActiveRecord::Base.transaction do
        import_file = ImportFileCache.create!(user: @user, zip_file: @zip_file)
        ProformaService::ConvertZipToTasks.call(zip_file: @zip_file).each do |task|
          exercise = Exercise.find_by_uuid(task[:uuid])

          data[SecureRandom.uuid] = {path: task[:path].tr(' ', '_'),
                                     exists: exercise.present?,
                                     updatable: exercise&.updatable_by?(@user) || false,
                                     import_id: import_file.id,
                                     exercise_uuid: task[:uuid]}
        end
        import_file.update!(data: data)
      end
      data
    end
  end
end
