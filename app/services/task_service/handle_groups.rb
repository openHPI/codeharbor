# frozen_string_literal: true

module TaskService
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

      groups = @group_tasks_params[:group_ids].filter(&:present?).map(&:to_i).map {|gid| Group.find(gid) }
      remove_groups(@task.groups - groups)
      add_groups(groups - @task.groups)
    end

    def add_groups(groups)
      groups.each do |group|
        next unless ability.can? :add_task, group

        @task.groups << group
      end
    end

    def remove_groups(groups)
      groups.each do |group|
        next unless ability.can? :remove_task, group

        @task.groups.destroy(group)
      end
    end

    def ability
      @ability ||= Ability.new(@user)
    end
  end
end
