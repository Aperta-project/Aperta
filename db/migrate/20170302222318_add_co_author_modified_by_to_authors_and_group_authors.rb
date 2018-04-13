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

class AddCoAuthorModifiedByToAuthorsAndGroupAuthors < ActiveRecord::Migration
  def up
    add_column :authors, :co_author_state_modified_by_id, :integer
    add_column :group_authors, :co_author_state_modified_by_id, :integer
    add_foreign_key :authors, :users, column: :co_author_state_modified_by_id
    add_foreign_key :group_authors, :users, column: :co_author_state_modified_by_id
  end

  def down
    remove_foreign_key :authors, :users, column: :co_author_state_modified_by_id
    remove_foreign_key :authors, :users, column: :co_author_state_modified_by_id
    remove_column :authors, :co_author_state_modified_by_id, :integer
    remove_column :group_authors, :co_author_state_modified_by_id, :integer
  end
end
