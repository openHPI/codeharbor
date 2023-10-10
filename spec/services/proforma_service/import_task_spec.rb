# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ImportTask do
  describe '.new' do
    subject(:import_proforma_task) { described_class.new(proforma_task:, user:) }

    let(:proforma_task) { ProformaXML::Task.new }
    let(:user) { build(:user) }

    it 'assigns proforma_task' do
      expect(import_proforma_task.instance_variable_get(:@proforma_task)).to be proforma_task
    end

    it 'assigns user' do
      expect(import_proforma_task.instance_variable_get(:@user)).to be user
    end
  end

  describe '#execute' do
    subject(:import_proforma_task) { described_class.call(proforma_task:, user:) }

    let(:proforma_task) { ProformaService::ConvertTaskToProformaTask.call(task:) }
    let(:task) { build(:task, title: 'proforma_task import title', user: task_user) }
    let(:task_user) { user }
    let(:user) { create(:user) }

    it 'creates an task in db' do
      expect { import_proforma_task }.to change(Task, :count).by(1)
    end

    it 'creates an task based on proforma_task' do
      expect(import_proforma_task).to have_attributes(title: 'proforma_task import title', uuid: be_a(String))
    end

    context 'when proforma_task does not provide valid information' do
      let(:proforma_task) { ProformaXML::Task.new }

      it 'does not create an task in db' do
        expect { import_proforma_task }.to raise_error(ActiveRecord::RecordInvalid).and(avoid_change(Task, :count))
      end
    end

    context 'when task with same uuid exists in db' do
      let!(:task) { create(:task, title: 'proforma_task import title', user: task_user).reload }

      it 'does not create a new task in db' do
        expect { import_proforma_task }.not_to change(Task, :count)
      end

      it 'changes existing task' do
        expect(import_proforma_task).to eql task
      end

      it 'creates a predecessor for task', pending: 'task relations are currently not available' do
        expect { import_proforma_task }.to change { task.reload.predecessor }.from(nil).to(be_an(Task))
      end

      context 'when user does not own task' do
        let(:task_user) { create(:user) }

        it 'creates an task in db' do
          expect { import_proforma_task }.to change(Task, :count).by(1)
        end

        it 'creates a new task' do
          expect(import_proforma_task).not_to eql task
        end

        context 'when user is an author of task', pending: 'tasks currently have one author only' do
          before { task.authors << user }

          it 'creates a new task' do
            expect(import_proforma_task).to eql task
          end

          it 'changes existing task' do
            expect { import_proforma_task }.to change(Task, :count).by(1)
          end

          it 'creates a predecessor for task' do
            expect { import_proforma_task }.to change { task.reload.predecessor }.from(nil).to(be_an(Task))
          end
        end
      end

      context 'when proforma_task does not provide valid information' do
        let(:proforma_task) { ProformaXML::Task.new(uuid: task.uuid) }

        it 'does not create an task in db' do
          expect { import_proforma_task }.to raise_error(ActiveRecord::RecordInvalid).and(avoid_change(Task, :count))
        end
      end
    end
  end
end
