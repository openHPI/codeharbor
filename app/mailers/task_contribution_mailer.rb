# frozen_string_literal: true

class TaskContributionMailer < ApplicationMailer
  def contribution_request(task_contrib)
    @task_author = task_contrib.base.user
    @task_contrib = task_contrib
    @contrib_author = task_contrib.suggestion.user
    I18n.with_locale(@task_author.preferred_locale || I18n.default_locale) do
      mail(to: @task_author.email,
        subject: t('task_contributions.mailer.contribution_request.subject_message', contrib_author: @contrib_author,
          task: @task_contrib.base.title))
    end
  end

  def approval_info(task_contrib)
    @task_contrib = task_contrib
    @contrib_author = task_contrib.suggestion.user
    I18n.with_locale(@contrib_author.preferred_locale || I18n.default_locale) do
      mail(to: @contrib_author.email,
        subject: t('task_contributions.mailer.approval_info.subject_message', task: @task_contrib.base.title))
    end
  end

  def rejection_info(task_contrib, duplicate)
    @task_contrib = task_contrib
    @contrib_author = task_contrib.suggestion.user
    @duplicate = duplicate
    I18n.with_locale(@contrib_author.preferred_locale || I18n.default_locale) do
      mail(to: @contrib_author.email,
        subject: t('task_contributions.mailer.rejection_info.subject_message', task: @task_contrib.base.title))
    end
  end
end
