# frozen_string_literal: true

require 'factory_bot_rails'

class TaskContributionMailerPreview < ActionMailer::Preview
  def send_contribution_request
    base = FactoryBot.build(:task, id: 1)
    task_contribution = FactoryBot.build(:task_contribution, base:, id: 2)
    TaskContributionMailer.contribution_request(task_contribution)
  end

  def send_approval_info
    base = FactoryBot.build(:task, id: 1)
    task_contribution = FactoryBot.build(:task_contribution, base:, id: 2)
    TaskContributionMailer.approval_info(task_contribution)
  end

  def send_rejection_info
    base = FactoryBot.build(:task, id: 1)
    duplicate = FactoryBot.build(:task, parent: base, id: 3)
    task_contribution = FactoryBot.build(:task_contribution, base:, id: 2)
    TaskContributionMailer.rejection_info(task_contribution, duplicate)
  end
end
