# frozen_string_literal: true

require_relative '../scripts/copy_data'

class MoveSolidQueueToDedicatedDatabase < ActiveRecord::Migration[7.1]
  include CopyData
  include ActiveRecord::Tasks

  class Queue < ApplicationRecord
    self.abstract_class = true
    connects_to database: {writing: :queue}
  end

  def up
    create_database(:queue)
    load_queue_schema(database: :queue)
    copy_data(source_connection: connection, target_connection: Queue.connection, operation: :matches, condition: 'solid_queue_%')
    drop_queue_tables(connection:)
  ensure
    Queue.connection&.disconnect!
  end

  def down
    load_queue_schema(database: :primary)
    copy_data(source_connection: Queue.connection, target_connection: connection, operation: :matches, condition: 'solid_queue_%')
    drop_queue_tables(connection: Queue.connection)
  rescue StandardError
    Queue.connection&.disconnect!
  else
    Queue.connection&.disconnect!
    drop_database(:queue)
  end

  def foreign_key_targets
    %w[
      solid_queue_jobs
    ]
  end

  private

  def load_queue_schema(database:)
    with_connection(database:) do
      DatabaseTasks.load_schema(configs_for(:queue), ActiveRecord.schema_format, 'db/queue_schema.rb')
    end
  end

  def drop_queue_tables(connection:)
    connection.drop_table :solid_queue_semaphores
    connection.drop_table :solid_queue_scheduled_executions
    connection.drop_table :solid_queue_recurring_tasks
    connection.drop_table :solid_queue_recurring_executions
    connection.drop_table :solid_queue_ready_executions
    connection.drop_table :solid_queue_processes
    connection.drop_table :solid_queue_pauses
    connection.drop_table :solid_queue_failed_executions
    connection.drop_table :solid_queue_claimed_executions
    connection.drop_table :solid_queue_blocked_executions
    connection.drop_table :solid_queue_jobs
  end

  def configs_for(name)
    ActiveRecord::Base.configurations.configs_for(name: name.to_s, env_name: Rails.env)
  end

  def create_database(name)
    database_name = configs_for(name).database
    new_primary_connection.create_database(database_name)
  rescue ActiveRecord::DatabaseAlreadyExists
    # Database already exists, do nothing
  end

  def drop_database(name)
    database_name = configs_for(name).database
    new_primary_connection.drop_database(database_name)
  end

  def new_primary_connection
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new(configs_for(:primary).configuration_hash)
  end

  def with_connection(database:)
    # We must not overwrite the `connection`, which is automatically overwritten by establishing a new connection.
    # However, we need to specify another connection, i.e. for loading the schema to the desired database.
    # Hence, we use this monkey patching workaround to change the connection temporary and then revert back.
    klass = database == :queue ? Queue : ApplicationRecord
    DatabaseTasks.alias_method :previous_migration_class, :migration_class
    DatabaseTasks.define_method(:migration_class) { klass }
    yield
  ensure
    DatabaseTasks.alias_method :migration_class, :previous_migration_class
  end
end
