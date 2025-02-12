# frozen_string_literal: true

class TaskService
  class HandleGroups < ServiceBase
    def initialize(user:, task:, group_tasks_params:)
      super()
      @user = user
      @task = task
      @group_tasks_params = group_tasks_params
    end

    def execute
      handle_groups
    end

    private

    def handle_groups
      return unless @group_tasks_params

      groups = @group_tasks_params[:group_ids].compact_blank.map(&:to_i).map {|gid| Group.find(gid) }
      remove_groups(@task.groups - groups)
      add_groups(groups - @task.groups)
    end

    def add_groups(groups)
      groups.each do |group|
        next unless Pundit.policy(@user, group).add_task?

        @task.groups << group
      end
    end

    def remove_groups(groups)
      groups.each do |group|
        next unless Pundit.policy(@user, group).remove_task?

        @task.groups.destroy(group)
      end
    end
  end
end
