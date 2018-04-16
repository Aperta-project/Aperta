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

class PermissionNotNulls < ActiveRecord::Migration
  def change
    change_column_null :permission_states, :name, false
    change_column_null :permission_states, :created_at, false
    change_column_null :permission_states, :updated_at, false

    change_column_null :permission_states_permissions, :permission_id, false
    change_column_null :permission_states_permissions, :permission_state_id, false
    change_column_null :permission_states_permissions, :created_at, false
    change_column_null :permission_states_permissions, :updated_at, false

    change_column_null :permissions, :action, false
    change_column_null :permissions, :applies_to, false
    change_column_null :permissions, :created_at, false
    change_column_null :permissions, :updated_at, false

    change_column_null :permissions_roles, :permission_id, false
    change_column_null :permissions_roles, :role_id, false
    change_column_null :permissions_roles, :created_at, false
    change_column_null :permissions_roles, :updated_at, false

    change_column_null :assignments, :user_id, false
    change_column_null :assignments, :role_id, false
    change_column_null :assignments, :assigned_to_id, false
    change_column_null :assignments, :assigned_to_type, false
    change_column_null :assignments, :created_at, false
    change_column_null :assignments, :updated_at, false

    change_column_null :roles, :name, false
    change_column_null :roles, :created_at, false
    change_column_null :roles, :updated_at, false
  end
end
