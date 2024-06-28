# frozen_string_literal: true

class NbpPushAllJob < ApplicationJob
  def perform
    Task.find_each(batch_size: 50) do |task|
      NbpPushJob.perform_later task
    end
  end
end
