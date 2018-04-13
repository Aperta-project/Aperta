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

# Removes old question database table
class DropQuestionTable < ActiveRecord::Migration
  def up
    execute("DELETE FROM question_attachments WHERE question_type = 'Question'")
    drop_table :questions

    remove_column :question_attachments, :question_type
    rename_column :question_attachments, :question_id, \
                  :nested_question_answer_id

    remove_column :authors, :corresponding
    remove_column :authors, :deceased
    remove_column :authors, :contributions

    remove_column :tahi_standard_tasks_funders, :funder_had_influence
    remove_column :tahi_standard_tasks_funders, :funder_influence_description
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
