module Tahi
  module AssignTeam
    class AssignTeamTask < Task

      # uncomment the following line if you want to enable event
      # streaming for this model
      # include EventStreamNotifier

      register_task default_title: 'Assign Team', default_role: 'admin'

      def assignments
        paper.paper_roles
      end

      def active_model_serializer
        AssignTeamTaskSerializer
      end
    end
  end
end
