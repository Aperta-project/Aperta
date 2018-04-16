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

# rubocop:disable all
# Add basic User role, and assign user to themselves.
class AddRolesAndPermissionsToProfilePage < ActiveRecord::Migration
  class PermissionState < ActiveRecord::Base
  end

  class Permission < ActiveRecord::Base
    has_and_belongs_to_many :states, class_name: 'PermissionState'
  end

  class Role < ActiveRecord::Base
    has_and_belongs_to_many :permissions
  end

  class User < ActiveRecord::Base
  end

  class Assignment < ActiveRecord::Base
  end

  def up
    # Add '*' permission state
    # Add :view_profile permission
    # Add User role
    # Assign every User to User role

    PermissionState.reset_column_information
    state = PermissionState.where(name: '*').first_or_create!

    Permission.reset_column_information
    permission = Permission.where(
      action: :view_profile,
      applies_to: 'User'
    ).first_or_create!
    permission.states  = (permission.states + [state]).uniq

    Role.reset_column_information
    role = Role.where(
      name: 'User',
      journal_id: nil # this role is not bound to a Journal
    ).first_or_create!
    role.permissions = (role.permissions + [permission]).uniq

    User.reset_column_information
    Assignment.reset_column_information
    User.all.map do |user|
      Assignment.create!(
        user_id: user.id,
        role_id: role.id,
        assigned_to_id: user.id,
        assigned_to_type: 'User'
      )
    end
  end

  def down
    # We only delete the assignment because we don't know for certain if we
    # created the Role, Permission, or PermissionState.
    Assignment.reset_column_information
    Assignment.delete_all
  end
end
# rubocop:enable all
