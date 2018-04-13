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

class DefaultValueForTaskTemplatesTemplate < ActiveRecord::Migration
  def up
    execute "ALTER TABLE task_templates ALTER COLUMN template SET DEFAULT '[]'::JSON"
    execute "UPDATE task_templates SET template = '[]' WHERE template IS NULL"
    change_column :task_templates, :template, :json, null: false
  end

  def down
    execute "ALTER TABLE task_templates ALTER COLUMN template DROP DEFAULT"
    change_column :task_templates, :template, :json, null: true
    execute "UPDATE task_templates SET template = NULL WHERE template::text = '[]'::text"
  end
end
