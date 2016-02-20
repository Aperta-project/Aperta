# rubocop:disable all
# These changes are necessary for the yaml_db gem which is being used to dump
# and load seed data.
#
# By default, if there are foreign key constraints that are enforced at the
# database, it will fail because the foreign record does not yet exist.  The
# fix for this is to defer foreign key constraints so that they are not
# enforced until the transaction is committed.
#
module YamlDb
  module SerializationHelper
    class Load
      def self.load(io, truncate = true)
        # First, make all foreign key constraints deferrable
        tc = Arel::Table.new('information_schema.table_constraints')
        arel = tc.project(tc[:constraint_name], tc[:table_name])
               .where(tc[:constraint_type].eq('FOREIGN KEY'))
        ActiveRecord::Base.connection.execute(arel.to_sql).each do |row|
          ActiveRecord::Base.connection.execute(
            # Set the deferrable flag on each constraint
            "ALTER TABLE #{row['table_name']} ALTER CONSTRAINT #{row['constraint_name']} DEFERRABLE INITIALLY DEFERRED")
        end

        # Now load everything in a transaction
        ActiveRecord::Base.connection.transaction do
          # Disable truncation when loading for three reasons:
          # 1. The database should already be empty, we are seeding it.
          # 2. A rake task called db:load should not delete data.
          # 3. It doesn't work properly with foreign key constraints.
          load_documents(io, false)
        end
      end
    end

    class Dump
      def self.tables
        ActiveRecord::Base.connection.tables.reject { |table| ['schema_info', 'schema_migrations'].include?(table) }.sort
      end
    end
  end
end
# rubocop:enable all
