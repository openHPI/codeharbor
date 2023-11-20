# frozen_string_literal: true

class TaskContributionMailer < ApplicationMailer
  def send_contribution_request(task_author, task_contrib, contrib_author)
    @task_author = task_author
    @task_contrib = task_contrib
    @contrib_author = contrib_author
    mail(to: @task_author.email, subject: "#{@contrib_author.name} wants to contribute to your Task '#{task_contrib.base_task.title}'")
  end

  def send_approval_info(task_contrib)
    @task_contrib = task_contrib
    @contrib_author = task_contrib.modifying_task.user
    mail(to: @contrib_author.email, subject: "#{@contrib_author.name} your contribution for '#{task_contrib.base_task.title}' was approved.")
  end

  def send_rejection_info(task_contrib)
    @task_contrib = task_contrib
    @contrib_author = task_contrib.modifying_task.user
    mail(to: @contrib_author.email, subject: "#{@contrib_author.name} your contribution for '#{task_contrib.base_task.title}' was rejected.")
  end
end
