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

class PaperRole < ActiveRecord::Base
end

class ConvertPaperRoleFlags < ActiveRecord::Migration
  def up
    add_column :paper_roles, :role, :string

    PaperRole.where(reviewer: true).update_all(role: 'reviewer')
    PaperRole.where(editor: true).update_all(role: 'editor')
    PaperRole.where(admin: true).update_all(role: 'admin')

    remove_column :paper_roles, :reviewer
    remove_column :paper_roles, :editor
    remove_column :paper_roles, :admin

    add_index :paper_roles, :role
  end

  def down
    add_column :paper_roles, :reviewer, :boolean, default: false, null: false
    add_column :paper_roles, :editor, :boolean, default: false, null: false
    add_column :paper_roles, :admin, :boolean, default: false, null: false

    PaperRole.where(role: 'reviewer').update_all(reviewer: true)
    PaperRole.where(role: 'editor').update_all(editor: true)
    PaperRole.where(role: 'admin').update_all(admin: true)

    remove_column :paper_roles, :role
  end
end
