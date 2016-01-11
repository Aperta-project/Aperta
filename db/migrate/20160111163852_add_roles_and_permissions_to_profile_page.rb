# rubocop:disable all
# Add basic User role, and assign user to themselves.
class AddRolesAndPermissionsToProfilePage < ActiveRecord::Migration
  class State < ActiveRecord::Base
  end

  class Permission < ActiveRecord::Base
    has_and_belongs_to_many :states
  end

  class Role < ActiveRecord::Base
    has_and_belongs_to_many :permissions
  end

  class User < ActiveRecord::Base
  end

  class Assignment < ActiveRecord::Base
  end

  def up
    # Add '*' state
    # Add :view_profile permission
    # Add User role
    # Assign every User to User role

    State.reset_column_information
    state = State.where(name: '*').first_or_create!

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
    # created the Role, Permission, or State.
    Assignment.reset_column_information
    Assignment.delete_all
  end
end
# rubocop:enable all
