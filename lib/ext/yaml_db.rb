# rubocop:disable all
# These changes are necessary for the yaml_db gem which is being used to dump
# and load seed data.
#
# By default, if there are foreign key constraints that are enforced at the
# database, it will fail because the foreign record does not yet exist.  The
# fix for this is to defer foreign key constraints so that they are not
# enforced until the transaction is committed. In addition, changes need made
# to yaml_db to support defered constraints.
#
# See:
# https://github.com/SchemaPlus/schema_plus/wiki/Making-yaml_db-work-with-foreign-key-constraints-in-PostgreSQL
module YamlDb
  module SerializationHelper
    class Base
      def load(filename, truncate = true)
        disable_logger
        ActiveRecord::Base.connection.disable_referential_integrity do
          @loader.load(File.new(filename, "r"), truncate)
        end
        reenable_logger
      end
    end

    class Load
      def self.truncate_table(table)
        begin
          ActiveRecord::Base.connection.execute("SAVEPOINT before_truncation")
          ActiveRecord::Base.connection.execute("TRUNCATE #{SerializationHelper::Utils.quote_table(table)}")
        rescue Exception => ex
          puts <<-MSG.strip_heredoc
            Recovering from the DB not being able to TRUNCATE. Falling back to DELETE.
            Please ignore any errors previous errors about not being able to truncate table '#{table}'.
          MSG

          ActiveRecord::Base.connection.execute("ROLLBACK TO SAVEPOINT before_truncation")
          ActiveRecord::Base.connection.execute("DELETE FROM #{SerializationHelper::Utils.quote_table(table)}")
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
