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

    # Returns a Authorizations::Query::ResultSet containing a subset of the
    # objects in target, and, for each object, a permission map containing a set
    # of actions and states describing the users access to that object.
    #
    # If permission is :*, the results will include any object for which the
    # user has any permission.
    #
    # If the permission is an action, e.g. :view, the results will include any
    # member of target for which the user has the :view permission.
    #
    # The object permission hash will be incomplete if the permission is not :*,
    # and will only contain the permission you passed in.
    #
    # TODO: This method is confusing and does too many things. We should improve
    # it.
    def filter_authorized(permission, target, participations_only: :default)
      Authorizations::Query.new(
        permission: permission,
        target: target,
        user: self,
        participations_only: participations_only
      ).all
    end

    def filter_authorized_set(permissions, target, participations_only: :default)
      journal_array = []
      permissions.each do |permission|
        journals = filter_authorized(
          permission,
          target,
          participations_only: :participations_only
        )
        journal_array += journals.objects
      end

      journal_array.uniq
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
