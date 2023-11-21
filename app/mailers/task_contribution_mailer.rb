# frozen_string_literal: true

class TaskContributionMailer < ApplicationMailer
  def contribution_request(task_contrib)
    @task_author = task_contrib.base_task.user
    @task_contrib = task_contrib
    @contrib_author = task_contrib.modifying_task.user
    mail(to: @task_author.email, subject: "#{@contrib_author.name} wants to contribute to your Task '#{task_contrib.base_task.title}'")
  end

  def approval_info(task_contrib)
    @task_contrib = task_contrib
    @contrib_author = task_contrib.modifying_task.user
    mail(to: @contrib_author.email,
      subject: "#{@contrib_author.name} your contribution for '#{task_contrib.base_task.title}' was approved.")
  end

  def rejection_info(task_contrib)
    @task_contrib = task_contrib
    @contrib_author = task_contrib.modifying_task.user
    mail(to: @contrib_author.email,
      subject: "#{@contrib_author.name} your contribution for '#{task_contrib.base_task.title}' was rejected.")
  end
end
