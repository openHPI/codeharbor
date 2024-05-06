# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskService::HandleGroups do
  describe '.new' do
    subject(:export_service) { described_class.new(user:, task:, group_tasks_params:) }

    let(:user) { build(:user) }
    let(:task) { build(:task, user:) }
    let(:group_tasks_params) { {} }

    it 'assigns user' do
      expect(export_service.instance_variable_get(:@user)).to be user
    end

    it 'assigns task' do
      expect(export_service.instance_variable_get(:@task)).to be task
    end

    it 'assigns group_tasks_params' do
      expect(export_service.instance_variable_get(:@group_tasks_params)).to be group_tasks_params
    end
  end

  describe '#execute' do
    subject(:handle_groups_service) { described_class.call(user:, task:, group_tasks_params:) }

    let(:user) { build(:user) }
    let(:task) { create(:task, user:) }
    let(:group) { create(:group, group_memberships:) }
    let(:group_memberships) { build_list(:group_membership, 1, :with_admin, user:) }
    let(:group_tasks_params) { {group_ids: ['', group.id.to_s]} }

    it 'adds the group to the task' do
      expect { handle_groups_service }.to change { task.reload.groups }.from([]).to([group])
    end

    context 'when user is no admin of group' do
      let(:group_memberships) { [build(:group_membership, user:), build(:group_membership, :with_admin)] }

      it 'does not add the group to the task' do
        expect { handle_groups_service }.not_to change { task.reload.groups.length }
      end
    end

    context 'when group_tasks_params contain id' do
      let(:group_tasks_params) { {group_ids: ['', group.id.to_s, group2.id.to_s]} }
      let(:group2) { create(:group, group_memberships: group_memberships2) }
      let(:group_memberships2) { build_list(:group_membership, 1, :with_admin, user:) }

      it 'adds the groups to the task' do
        expect { handle_groups_service }.to change { task.reload.groups }.from([]).to(contain_exactly(group, group2))
      end
    end

    context 'when task already has a group' do
      let(:task) { create(:task, user:, groups: [group]) }

      it 'does change the groups of the task' do
        expect { handle_groups_service }.not_to change { task.reload.groups.length }
      end

      context 'when group_tasks_params do not contain group_id' do
        let(:group_tasks_params) { {group_ids: ['']} }

        it 'removes the group to the task' do
          expect { handle_groups_service }.to change { task.reload.groups }.from([group]).to([])
        end

        context 'when user is no admin of group' do
          let(:group_memberships) { [build(:group_membership, user:), build(:group_membership, :with_admin)] }

          it 'does change the groups of the task' do
            expect { handle_groups_service }.not_to change { task.reload.groups.length }
          end
        end
      end
    end

    context 'when group_tasks_params are nil' do
      let(:group_tasks_params) {}

      it 'does change the groups of the task' do
        expect { handle_groups_service }.not_to change { task.reload.groups.length }
      end
    end
  end
end
