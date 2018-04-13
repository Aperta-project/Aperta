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

# Tasks have papers through phases currently in the app. This migration
# makes it so tasks have a direct relationship to paper. This simplifies
# queries for how tasks are looked up on papers (which is very often).
class AddPaperIdToTask < ActiveRecord::Migration
  def up
    add_column :tasks, :paper_id, :integer
    add_index :tasks, :paper_id

    execute <<-SQL
      UPDATE tasks
      SET paper_id=phases.paper_id
      FROM phases
      WHERE phase_id=phases.id
    SQL

    change_column :tasks, :paper_id, :integer, null: false
  end

  def down
    remove_column :tasks, :paper_id
  end
end
