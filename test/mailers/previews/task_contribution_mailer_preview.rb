# frozen_string_literal: true

require 'factory_bot_rails'
class TaskContributionMailerPreview < ActionMailer::Preview
  def contribution_request
    author = FactoryBot.build(:user)
    contrib_author = FactoryBot.build(:user)
    base_task = FactoryBot.create(:task, user: author)
    modifying_task = FactoryBot.build(:task, parent_uuid: base_task.uuid, user: contrib_author)
    task_contrib = FactoryBot.create(:task_contribution, modifying_task:)

    TaskContributionMailer.contribution_request(task_contrib)
  end

  def approval_info
    author = FactoryBot.build(:user)
    contrib_author = FactoryBot.build(:user)
    base_task = FactoryBot.create(:task, user: author)
    modifying_task = FactoryBot.build(:task, parent_uuid: base_task.uuid, user: contrib_author)
    task_contrib = FactoryBot.create(:task_contribution, modifying_task:)

    TaskContributionMailer.approval_info(task_contrib)
  end

  def rejection_info
    author = FactoryBot.build(:user)
    contrib_author = FactoryBot.build(:user)
    base_task = FactoryBot.create(:task, user: author)
    modifying_task = FactoryBot.build(:task, parent_uuid: base_task.uuid, user: contrib_author)
    task_contrib = FactoryBot.create(:task_contribution, modifying_task:)

    TaskContributionMailer.rejection_info(task_contrib)
  end
end
