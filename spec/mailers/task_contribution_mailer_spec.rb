# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskContributionMailer do
  let(:task) { create(:task) }
  let(:task_contrib) { create(:task_contribution) }

  describe '#contribution_request' do
    subject(:contribution_request) { described_class.contribution_request(task_contrib) }

    it 'sends an email' do
      expect(contribution_request.to).to include(task_contrib.base.user.email)
      expect(contribution_request.subject).to include(task_contrib.suggestion.user.name)
      expect(contribution_request.subject).to include(task_contrib.base.title)
    end

    it 'contains the correct contents' do
      expect(contribution_request.body.encoded).to include(task_contrib.suggestion.user.name)
      expect(contribution_request.body.encoded).to include(task_contrib.base.title)
      expect(contribution_request.body.encoded).to include('suggested changes')
    end
  end

  describe '#approval_info' do
    subject(:approval_info) { described_class.approval_info(task_contrib) }

    it 'sends an email' do
      expect(approval_info.to).to include(task_contrib.suggestion.user.email)
      expect(approval_info.subject).to include(task_contrib.base.title)
    end

    it 'contains the correct contents' do
      expect(approval_info.body.encoded).to include(task_contrib.base.title)
      expect(approval_info.body.encoded).to include('was approved')
    end
  end

  describe '#rejection_info' do
    subject(:rejection_info) { described_class.rejection_info(task_contrib, duplicate_task) }

    let(:duplicate_task) { create(:task) }

    it 'sends an email' do
      expect(rejection_info.to).to include(task_contrib.suggestion.user.email)
      expect(rejection_info.subject).to include(task_contrib.base.title)
    end

    it 'contains the correct contents' do
      expect(rejection_info.body.encoded).to include(task_contrib.base.title)
      expect(rejection_info.body.encoded).to include('was rejected')
    end
  end
end
