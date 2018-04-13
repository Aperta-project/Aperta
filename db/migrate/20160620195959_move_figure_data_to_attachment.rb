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

# Remove move figures table data to attachments, remove figures table.
class MoveFigureDataToAttachment < ActiveRecord::Migration
  def up
    figure_count = count 'figures'
    starting_attachment_count = count 'attachments'

    execute <<-SQL
      INSERT INTO attachments
            (old_id, owner_id, owner_type, file,       title, caption, status, token, type,     s3_dir, created_at, updated_at)
      SELECT id, paper_id, 'Paper',    attachment, title, caption, status, token, 'Figure', s3_dir,created_at, updated_at
      FROM figures
    SQL

    ending_attachment_count = count 'attachments'
    delta = ending_attachment_count - starting_attachment_count - figure_count
    unless delta == 0
      fail "Expected to move all the figures to the attachments table, but was off by #{delta}"
    end
    drop_table :figures
  end

  def down
    create_table "figures" do |t|
      t.string   "attachment"
      t.integer  "paper_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
      t.text     "caption"
      t.string   "status",     default: "processing"
      t.string   "token"
      t.text     "s3_dir"
    end

    execute <<-SQL
      INSERT INTO figures
            (id,     paper_id, title, caption, attachment, created_at, updated_at, status, token, s3_dir)
      SELECT old_id, owner_id, title, caption, file,       created_at, updated_at, status, token, s3_dir
      FROM attachments
      WHERE type='Figure'
    SQL

    add_index "figures", ["paper_id"], name: "index_figures_on_paper_id", using: :btree
    add_index "figures", ["token"], name: "index_figures_on_token", unique: true, using: :btree

    execute <<-SQL
      DELETE FROM attachments
      WHERE type='Figure'
    SQL
  end

  private

  def count(table_name)
    column_name = "#{table_name}_count"
    sql_result = execute("SELECT COUNT(*) as #{column_name} FROM #{table_name}")
    sql_result.field_values(column_name).first.to_i
  end
end
