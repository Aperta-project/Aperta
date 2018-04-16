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

class ImproveCardVersions < ActiveRecord::Migration
  def change
    raise 'This migration does not migrate data' unless \
      count('card_versions').zero? &&
          count('card_contents').zero? &&
          count('cards').zero?
    remove_column :card_contents, :card_id
    add_column :card_contents, :card_version_id, :integer
    remove_column :card_versions, :card_content_id
  end

  def count(table_name)
    column_name = "#{table_name}_count"
    sql_result = execute("SELECT COUNT(id) as #{column_name} FROM #{table_name}")
    sql_result.field_values(column_name).first.to_i
  end
end
