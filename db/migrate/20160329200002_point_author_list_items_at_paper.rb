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

# Before, authors and groupAuthors belong to the AuthorsTask via
# AuthorListItems. They should belong to the *paper*, instead.
class PointAuthorListItemsAtPaper < ActiveRecord::Migration
  def up
    add_column :author_list_items, :paper_id, :integer
    add_foreign_key :author_list_items, :papers

    # Delete orphaned records before migrating data
    execute <<-SQL.strip_heredoc
      DELETE FROM authors
      WHERE authors.paper_id NOT IN (SELECT id FROM papers)
    SQL

    execute <<-SQL.strip_heredoc
      DELETE FROM author_list_items
      WHERE author_list_items.author_id NOT IN
      (SELECT id FROM authors) AND author_list_items.author_type = 'Author'
    SQL

    execute <<-SQL.strip_heredoc
      DELETE FROM group_authors
      WHERE group_authors.paper_id NOT IN (SELECT id FROM papers)
    SQL

    execute <<-SQL.strip_heredoc
      DELETE FROM author_list_items
      WHERE author_list_items.author_id NOT IN
      (SELECT id FROM group_authors) AND author_list_items.author_type = 'GroupAuthor'
    SQL

    # Migrate author paper assignments
    execute <<-SQL.strip_heredoc
      UPDATE author_list_items
      SET paper_id = authors.paper_id
      FROM authors WHERE authors.id = author_list_items.author_id
      AND author_list_items.author_type = 'Author'
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE author_list_items
      SET paper_id = group_authors.paper_id
      FROM group_authors WHERE group_authors.id = author_list_items.author_id
      AND author_list_items.author_type = 'GroupAuthor'
    SQL

    remove_column :author_list_items, :task_id
    remove_column :authors, :paper_id
    remove_column :group_authors, :paper_id
  end

  def down
    add_column :author_list_items, :task_id, :integer
    add_column :authors, :paper_id, :integer
    add_column :group_authors, :paper_id, :integer
    add_foreign_key :author_list_items, :tasks

    execute <<-SQL.strip_heredoc
      UPDATE author_list_items
      SET task_id = tasks.id
      FROM tasks WHERE tasks.paper_id = author_list_items.paper_id
      AND tasks.type = 'TahiStandardTasks::AuthorsTask'
    SQL

    remove_column :author_list_items, :paper_id
  end
end
