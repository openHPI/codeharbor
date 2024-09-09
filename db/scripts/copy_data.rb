# frozen_string_literal: true

module CopyData
  BATCH_SIZE = 500

  def copy_data(source_connection:, target_connection:, operation:, condition:)
    tables = tables(connection: source_connection, operation:, condition:)
    sequences = sequences(connection: source_connection, operation:, condition:)
    views = views(connection: source_connection, operation:, condition:)

    source_connection.transaction do
      target_connection.transaction do
        copy_tables(tables, source_connection:, target_connection:)
        copy_sequences(sequences, source_connection:, target_connection:)
        copy_views(views, source_connection:, target_connection:)
      end
    end
  end

  # Some tables or views might be referenced by other tables or views.
  # Those need to be handled first when copying data or last when removing columns.
  def foreign_key_targets
    []
  end

  private

  def copy_tables(tables, source_connection:, target_connection:)
    return unless tables.any?

    # Lock tables to prevent new data from being added
    # As soon as the transaction is committed, the lock is released automatically
    quoted_table_names = tables.map {|table| source_connection.quote_table_name(table) }.join(', ')
    source_connection.execute("LOCK #{quoted_table_names} IN ACCESS EXCLUSIVE MODE")

    # Copy tables by fetching and inserting records in batches
    tables.each do |table|
      arel_table = Arel::Table.new(table)
      offset = 0

      loop do
        select_manager = arel_table.project(Arel.star).take(BATCH_SIZE).skip(offset)
        records = source_connection.execute(select_manager.to_sql)
        break if records.ntuples.zero?

        insert_manager = Arel::InsertManager.new
        insert_manager.into(arel_table)
        insert_manager.columns.concat(records.fields.map {|field| arel_table[field] })
        insert_manager.values = insert_manager.create_values_list(records.values)
        target_connection.execute(insert_manager.to_sql)

        offset += BATCH_SIZE
      end
    end
  end

  def copy_sequences(sequences, source_connection:, target_connection:)
    sequences.each do |sequence|
      sequence_table = Arel::Table.new(sequence)
      select_manager = sequence_table.project(sequence_table[:last_value])
      max_value = source_connection.execute(select_manager.to_sql).first['last_value']
      # Set sequence to the *next* value.
      target_connection.execute("ALTER SEQUENCE #{target_connection.quote_table_name(sequence)} RESTART WITH #{max_value + 1}")
    end
  end

  def copy_views(views, source_connection:, target_connection:)
    pg_views = Arel::Table.new('pg_views')

    views.each do |view|
      select_manager = pg_views.project(pg_views[:definition]).where(pg_views[:schemaname].eq('public').and(pg_views[:viewname].eq(view)))
      definition = source_connection.execute(select_manager.to_sql).first['definition']
      target_connection.execute("CREATE VIEW #{target_connection.quote_table_name(view)} AS #{definition}")
    end
  end

  def tables(connection:, operation: :matches, condition: '%')
    tables = query_for(connection:, kind: :table, operation:, condition:)
    tables.sort_by {|element| foreign_key_targets.index(element) || tables.size }
  end

  def sequences(connection:, operation: :matches, condition: '%')
    query_for(connection:, kind: :sequence, operation:, condition:)
  end

  def views(connection:, operation: :matches, condition: '%')
    query_for(connection:, kind: :view, operation:, condition:)
  end

  # @param connection [ActiveRecord::ConnectionAdapters::PostgreSQLAdapter]
  # @param kind [Symbol] :table, :sequence, or :view
  # @param operation [Symbol] :matches, :does_not_match, :eq, :not_eq, :lt, :lteq, :gt, :gteq
  # @param condition [String] The condition to match
  # @return [Array<String>] The names of the tables, sequences, or views that match the condition
  def query_for(connection:, kind:, operation:, condition:)
    table_name = :"information_schema.#{kind}s"
    column_name = :"#{kind == :view ? :table : kind}_name"
    schema_name = :"#{kind == :view ? :table : kind}_schema"

    information_schema = Arel::Table.new(table_name)

    query = information_schema
      .project(information_schema[column_name])
      .where(information_schema[schema_name].eq('public').and(information_schema[column_name].public_send(operation, condition)))

    connection.execute(query.to_sql).pluck(column_name.to_s)
  end
end
