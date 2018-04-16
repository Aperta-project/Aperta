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

class AddVersionedText < ActiveRecord::Migration
  def up
    create_table :versioned_texts do |t|
      t.integer :submitting_user_id, :references => [:users, :id]
      t.integer :paper_id, :references => [:paper, :id]
      t.integer :major_version, default: 0
      t.integer :minor_version, default: 0
      t.boolean :active, default: true
      t.boolean :copy_on_edit, default: false
      t.text :text, default: ""

      t.timestamps
    end

    execute(<<-statement)
      INSERT INTO versioned_texts
         (text, major_version, copy_on_edit)
      SELECT
         body, 0, publishing_state <> 'ongoing'
      FROM papers
    statement

    remove_column :papers, :body
  end

  def down
    # TODO restore paper bodies
    add_column :papers, :body, :text
    drop_table :versioned_texts
  end
end
