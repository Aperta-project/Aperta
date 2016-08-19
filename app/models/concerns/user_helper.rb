# Provides convenience/helper methods intended for use on the User model.
module UserHelper
  extend ActiveSupport::Concern

  included do
    has_many :assignments
    has_many :roles,
      -> { uniq },
      through: :assignments
  end

  class_methods do
    def who_can(permission, target)
      Authorizations::ReverseQuery.new(
        permission: permission,
        target: target
      ).all
    end
  end

  def can?(permission, target)
    # TODO: Remove this when site_admin is no more
    return true if site_admin
    filter_authorized(permission, target).objects.length > 0
  end

  def filter_authorized(permission, target, participations_only: :default)
    Authorizations::Query.new(
      permission: permission,
      target: target,
      user: self,
      participations_only: participations_only
    ).all
  end

  def assigned_to?(assigned_to:, role:)
    role = get_role_for_thing(assigned_to, role)
    Assignment.where(
      user: self,
      role: role,
      assigned_to: assigned_to
    ).exists?
  end

  def assign_to!(assigned_to:, role:)
    role = get_role_for_thing(assigned_to, role)
    Assignment.where(
      user: self,
      role: role,
      assigned_to: assigned_to
    ).first_or_create!
  end

  def resign_from!(assigned_to:, role:)
    role = get_role_for_thing(assigned_to, role)
    assignments.where(role: role, assigned_to: assigned_to).destroy_all
  end

  private

  # Return the role with the name `role_name` associated with a given thing.
  # Return role if role is already a Role.
  def get_role_for_thing(thing, role_name)
    return role_name if role_name.is_a?(Role)

    # role_name is a string, need to get the right role for the journal
    journal = thing.is_a?(Journal) ? thing : thing.try(:journal)
    unless journal
      fail <<-ERROR.strip_heredoc
        Expected #{thing} to be a journal or respond to journal method
      ERROR
    end
    Role.find_by!(journal: journal, name: role_name)
  end
end
