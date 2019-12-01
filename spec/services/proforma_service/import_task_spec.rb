# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProformaService::ImportTask do
  describe '.new' do
    subject(:import_task) { described_class.new(task: task, user: user) }

    let(:task) { Proforma::Task.new }
    let(:user) { build(:user) }

    it 'assigns task' do
      expect(import_task.instance_variable_get(:@task)).to be task
    end

    it 'assigns user' do
      expect(import_task.instance_variable_get(:@user)).to be user
    end
  end

  describe '#execute' do
    subject(:import_task) { described_class.call(task: task, user: user) }

    let(:task) { ProformaService::ConvertExerciseToTask.call(exercise: exercise) }
    let(:exercise) { build(:exercise, title: 'task import title', user: exercise_user) }
    let(:exercise_user) { user }
    let(:user) { create(:user) }

    it 'creates an exercise in db' do
      expect { import_task }.to change(Exercise, :count).by(1)
    end

    it 'creates an exercise based on task' do
      expect(import_task).to have_attributes(title: 'task import title', uuid: be_a(String))
    end

    context 'when task does not provide valid information' do
      let(:task) { Proforma::Task.new }

      it 'does not create an exercise in db' do
        expect { import_task }.to raise_error(ActiveRecord::RecordInvalid).and(change(Exercise, :count).by(0))
      end
    end

    context 'when exercise with same uuid exists in db' do
      let!(:exercise) { create(:exercise, title: 'task import title', user: exercise_user).reload }

      it 'creates an exercise in db' do
        expect { import_task }.to change(Exercise, :count).by(1)
      end

      it 'changes existing exercise' do
        expect(import_task).to eql exercise
      end

      it 'creates a predecessor for exercise' do
        expect { import_task }.to change { exercise.reload.predecessor }.from(nil).to(be_an(Exercise))
      end

      context 'when user does not own exercise' do
        let(:exercise_user) { create(:user) }

        it 'creates an exercise in db' do
          expect { import_task }.to change(Exercise, :count).by(1)
        end

        it 'creates a new exercise' do
          expect(import_task).not_to eql exercise
        end

        context 'when user is an author of exercise' do
          before { exercise.authors << user }

          it 'creates a new exercise' do
            expect(import_task).to eql exercise
          end

          it 'changes existing exercise' do
            expect { import_task }.to change(Exercise, :count).by(1)
          end

          it 'creates a predecessor for exercise' do
            expect { import_task }.to change { exercise.reload.predecessor }.from(nil).to(be_an(Exercise))
          end
        end
      end

      context 'when task does not provide valid information' do
        let(:task) { Proforma::Task.new(uuid: exercise.uuid) }

        it 'does not create an exercise in db' do
          expect { import_task }.to raise_error(ActiveRecord::RecordInvalid).and(change(Exercise, :count).by(0))
        end
      end
    end
  end
end
