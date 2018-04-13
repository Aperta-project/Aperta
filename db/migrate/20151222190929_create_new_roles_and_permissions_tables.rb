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

class CreateNewRolesAndPermissionsTables < ActiveRecord::Migration
  def change
    create_table 'assignments' do |t|
      t.integer  'user_id'
      t.integer  'role_id'
      t.integer  'assigned_to_id'
      t.string   'assigned_to_type'
      t.timestamps
    end

    create_table 'permissions' do |t|
      t.string   'action'
      t.string   'applies_to'
      t.timestamps
    end

    create_table 'permissions_roles' do |t|
      t.integer  'permission_id'
      t.integer  'role_id'
      t.timestamps
    end

    create_table 'permissions_states' do |t|
      t.integer  'permission_id'
      t.integer  'state_id'
      t.timestamps
    end

    create_table 'roles' do |t|
      t.string   'name'
      t.integer  'journal_id'
      t.boolean  'participates_in_papers', null: false, default: false
      t.boolean  'participates_in_tasks', null: false, default: false
      t.timestamps
    end

    create_table 'states' do |t|
      t.string   'name'
      t.timestamps
    end

  end
end
