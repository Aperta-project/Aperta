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

# Authors and GroupAuthors belong to the same list; this makes the
# class that joins them.
class AddAuthorListItem < ActiveRecord::Migration
  # Fake author so's changes to the code don't break this migration
  class Author < ActiveRecord::Base
    has_one :author_list_item
  end

  # Ditto
  class AuthorListItem < ActiveRecord::Base
  end

  def up
    create_table :author_list_items do |t|
      t.integer :position
      t.references :author, null: false, polymorphic: true
      t.references :task, null: false
      t.timestamps
    end

    Author.all.each do |author|
      AuthorListItem.create!(
        author_id: author.id,
        author_type: "Author",
        position: author.position,
        task_id: author.authors_task_id
      )
    end

    remove_column :authors, :authors_task_id
    remove_column :authors, :position
  end

  def down
    add_column :authors, :authors_task_id, :integer
    add_column :authors, :position, :integer

    Author.all.each do |author|
      author.update(
        authors_task_id: author.author_list_item.task_id,
        position: author.author_list_item.position
      )
    end

    drop_table :author_list_items
  end
end
