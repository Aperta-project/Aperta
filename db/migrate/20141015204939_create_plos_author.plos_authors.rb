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

# This migration comes from plos_authors (originally 20141015204939)
class CreatePlosAuthor < ActiveRecord::Migration
  def change
    create_table :plos_authors_plos_authors do |t|
      t.references :plos_authors_task
      t.string   :middle_initial
      t.string   :email
      t.string   :department
      t.string   :title
      t.boolean  :corresponding,         default: false, null: false
      t.boolean  :deceased,              default: false, null: false
      t.string   :affiliation
      t.string   :secondary_affiliation
      t.timestamps
    end

    change_table :authors do |t|
      t.string :actable_type
      t.integer :actable_id
    end

    remove_column :authors, :middle_initial, :string
    remove_column :authors, :email, :string
    remove_column :authors, :department, :string
    remove_column :authors, :title, :string
    remove_column :authors, :corresponding, :boolean, default: false, null: false
    remove_column :authors, :deceased,  :boolean, default: false, null: false
    remove_column :authors, :affiliation, :string
    remove_column :authors, :secondary_affiliation, :string
  end
end
