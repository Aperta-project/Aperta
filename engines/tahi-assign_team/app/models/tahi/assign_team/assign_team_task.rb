module Tahi
  module AssignTeam
    class AssignTeamTask < Task
      DEFAULT_TITLE = 'Assign Team'
      DEFAULT_ROLE = 'admin'

      def assignments
        paper.paper_roles
      end

      def active_model_serializer
        AssignTeamTaskSerializer
      end
    end
  end
end
