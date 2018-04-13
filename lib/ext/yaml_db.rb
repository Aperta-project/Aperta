# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
