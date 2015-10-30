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
        ActiveRecord::Base.connection.execute("TRUNCATE #{SerializationHelper::Utils.quote_table(table)} CASCADE")
      rescue Exception
        ActiveRecord::Base.connection.execute("ROLLBACK TO SAVEPOINT before_truncation")
        ActiveRecord::Base.connection.execute("DELETE FROM #{SerializationHelper::Utils.quote_table(table)}")
      end
    end
  end
end
