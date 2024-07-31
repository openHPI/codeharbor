# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskContribution do
  describe 'decouple' do
    let(:task_contribution) { create(:task_contribution) }

    describe 'when task_contribution is valid' do
      subject(:decoupled_task) { task_contribution.decouple }

      it 'returns a new persisted task' do
        expect(decoupled_task).to be_a(Task)
        expect(decoupled_task).to be_persisted
      end
    end

    describe 'when task_contribution is invalid', cleaning_strategy: :truncation do
      shared_examples 'no changes are saved' do
        it 'returns nil' do
          expect(task_contribution.decouple).to be_nil
        end

        it 'does not create a new task' do
          expect { task_contribution.decouple }.not_to change(Task, :count)
        end

        it 'does not update the status of the task_contribution' do
          expect { task_contribution.decouple }.not_to change(task_contribution, :status)
        end
      end

      context 'when saving fails' do
        before do
          allow(task_contribution.suggestion).to receive(:duplicate).and_return(Task.new)
        end

        it_behaves_like 'no changes are saved'
      end

      context 'when closing fails' do
        before do
          allow(task_contribution).to receive(:close).and_return(false)
        end

        it_behaves_like 'no changes are saved'
      end
    end
  end
end
