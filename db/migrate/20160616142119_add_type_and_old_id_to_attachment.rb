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

# Adds a single table inheritance column 'type' to attachments and defaults
# its value to AdhocAttachment since that is what this table currently
# stores. This also adds 'old_id' which is going to be used to keep
# around the old IDs as we migrate data in future migrations, should we need
# to rollback.
class AddTypeAndOldIdToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :type, :string
    add_column :attachments, :old_id, :integer

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE attachments
          SET type='AdhocAttachment', old_id=id
        SQL
      end
    end
  end
end
