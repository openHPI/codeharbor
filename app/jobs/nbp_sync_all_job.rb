# frozen_string_literal: true

class NbpSyncAllJob < ApplicationJob
  def perform
    uuids = Set[]

    # First, add all uploaded UUIDs.
    # This allows us to delete the ones that are still present remote but no longer in the local database.
    Nbp::PushConnector.instance.process_uploaded_task_uuids do |uuid|
      uuids.add(uuid)
    end

    # Then, add all local UUIDs.
    # This allows us to upload tasks missing remote (and remove private tasks not yet removed).
    Task.select(:id, :uuid).find_each {|task| uuids.add(task.uuid) }

    # Finally, schedule a full sync for each UUID identified.
    sync_jobs = uuids.map {|uuid| NbpSyncJob.new(uuid) }
    ActiveJob.perform_all_later(sync_jobs)
  end
end
