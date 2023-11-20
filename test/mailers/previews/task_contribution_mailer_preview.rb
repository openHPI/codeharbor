# frozen_string_literal: true
# Preview all emails at http://localhost:3000/rails/mailers/task_contribution_mailer

require 'factory_bot_rails'
class TaskContributionMailerPreview < ActionMailer::Preview
  def send_contribution_request
    author = FactoryBot.build(:user)
    contrib_author = FactoryBot.build(:user)
    base_task = FactoryBot.create(:task, user: author)
    modifying_task = FactoryBot.build(:task, parent_uuid: base_task.uuid, user: contrib_author)
    task_contrib = FactoryBot.create(:task_contribution, modifying_task:)

    TaskContributionMailer.send_contribution_request(author, task_contrib, contrib_author)
  end

  def send_approval_info
    author = FactoryBot.build(:user)
    contrib_author = FactoryBot.build(:user)
    base_task = FactoryBot.create(:task, user: author)
    modifying_task = FactoryBot.build(:task, parent_uuid: base_task.uuid, user: contrib_author)
    task_contrib = FactoryBot.create(:task_contribution, modifying_task:)

    TaskContributionMailer.send_approval_info(task_contrib)
  end

  def send_rejection_info
    author = FactoryBot.build(:user)
    contrib_author = FactoryBot.build(:user)
    base_task = FactoryBot.create(:task, user: author)
    modifying_task = FactoryBot.build(:task, parent_uuid: base_task.uuid, user: contrib_author)
    task_contrib = FactoryBot.create(:task_contribution, modifying_task:)

    TaskContributionMailer.send_rejection_info(task_contrib)
  end
end
