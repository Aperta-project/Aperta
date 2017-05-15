module Authorizations
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

      def site_admins
        with_role(Role.site_admin_role, assigned_to: System.first)
      end

      def with_role(role, assigned_to: nil)
        with_role_query = joins(assignments: :role).where(roles: { id: role })
        if assigned_to
          with_role_query.where(assignments: { assigned_to: assigned_to })
        else
          with_role_query
        end
      end
    end

    def can?(permission, target)
      !filter_authorized(
        permission, target, participations_only: false
      ).objects.empty?
    end

    def unaccepted_and_invited_to?(paper:)
      return false if paper.blank? || paper.draft_decision.nil?
      paper.draft_decision.invitations.where(state: 'invited', invitee_id: id).exists?
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

    def site_admin?
      assignments.includes(:permissions)
                 .where(
                   permissions: {
                     action: Permission::WILDCARD,
                     applies_to: System.name
                   }
                 ).exists?
    end

    private

    # Return the role with the name `role_name` associated with a given thing.
    # Return role if role is already a Role.
    def get_role_for_thing(thing, role_name)
      return role_name if role_name.is_a?(Role)

      # role_name is a string, need to get the right role for the journal
      journal = thing.is_a?(Journal) ? thing : thing.try(:journal)
      unless journal
        raise <<-ERROR.strip_heredoc
          Expected #{thing} to be a journal or respond to journal method
        ERROR
      end
      Role.find_by!(journal: journal, name: role_name)
    end
  end
end
