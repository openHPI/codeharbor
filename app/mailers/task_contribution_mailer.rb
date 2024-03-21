# frozen_string_literal: true

class TaskContributionMailer < ApplicationMailer
  def contribution_request(task_contrib)
    @task_author = task_contrib.base.user
    @task_contrib = task_contrib
    @contrib_author = task_contrib.suggestion.user
    mail(to: @task_author.email, subject: "#{@contrib_author.name} wants to contribute to your Task '#{task_contrib.base.title}'")
  end

  def approval_info(task_contrib)
    @task_contrib = task_contrib
    @contrib_author = task_contrib.suggestion.user
    mail(to: @contrib_author.email,
      subject: "Your contribution for '#{task_contrib.base.title}' was approved.")
  end

  def rejection_info(task_contrib)
    @task_contrib = task_contrib
    @contrib_author = task_contrib.suggestion.user
    mail(to: @contrib_author.email,
      subject: "Your contribution for '#{task_contrib.base.title}' was rejected.")
  end
end
