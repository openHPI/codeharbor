# frozen_string_literal: true

class NbpPushAllJob < ApplicationJob
  def perform
    Task.find_in_batches do |group|
      group.each {|task| NbpPushJob.perform_later task }
    end
  end
end
