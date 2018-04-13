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

# Move resource tokens into their own table
class AddResourceToken < ActiveRecord::Migration
  def up
    create_table :resource_tokens do |t|
      t.timestamps
      t.integer :owner_id
      t.string :owner_type
      t.string :token
    end

    add_index :resource_tokens, :token
    add_index :resource_tokens, [:owner_id, :owner_type]

    execute <<-SQL
      INSERT INTO resource_tokens (token, owner_id, owner_type,   created_at, updated_at)
      SELECT                       token, id,       'Attachment', created_at, created_at
      FROM attachments
    SQL
  end

  def down
    execute <<-SQL
      INSERT INTO attachments (token)
      SELECT                   token
      FROM resource_tokens
      WHERE owner_id = attachments.id AND owner_type = 'Attachment'
    SQL
    drop_table :resource_tokens
  end
end
