# frozen_string_literal: true

require 'factory_bot_rails'

class TaskContributionMailerPreview < ActionMailer::Preview
  def send_contribution_request
    base = FactoryBot.build(:task, id: 1)
    task_contribution = FactoryBot.build(:task_contribution, base:, id: 2)
    TaskContributionMailer.with(task_contrib: task_contribution).send_contribution_request
  end

  def send_approval_info
    base = FactoryBot.build(:task, id: 1)
    task_contribution = FactoryBot.build(:task_contribution, base:, id: 2)
    TaskContributionMailer.wtih(task_contrib: task_contribution).send_approval_info
  end

  def send_rejection_info
    base = FactoryBot.build(:task, id: 1)
    duplicate = FactoryBot.build(:task, parent: base, id: 3)
    task_contribution = FactoryBot.build(:task_contribution, base:, id: 2)
    TaskContributionMailer.with(task_contrib: task_contribution, duplicate:).send_rejection_info
  end
end
