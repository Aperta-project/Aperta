module Tahi
  module AssignTeam
    # The AssignTeamTask represents the part of the paper workflow
    # responsible for assigning users to various roles on a paper.
    class AssignTeamTask < Task
      DEFAULT_TITLE = 'Assign Team'
      DEFAULT_ROLE = 'admin'

      def assignable_roles
        [
          journal.academic_editor_role,
          journal.cover_editor_role,
          journal.handling_editor_role,
          journal.reviewer_role
        ]
      end

      def assignments
        paper.assignments.where(role_id: assignable_roles)
      end

      def active_model_serializer
        AssignTeamTaskSerializer
      end
    end
  end
end
