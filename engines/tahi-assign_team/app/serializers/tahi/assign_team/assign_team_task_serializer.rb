module Tahi
  module AssignTeam
    # The AssignTeamTaskSerializer is responsible for serializing an
    # AssignTeamTask model as an API response.
    class AssignTeamTaskSerializer < ::TaskSerializer
      has_many \
        :assignments,
        embed: :ids,
        include: true,
        each_serializer: AssignmentSerializer,
        serializer: AssignmentSerializer

      has_many \
        :assignable_roles,
        embed: :ids,
        include: true,
        each_serializer: RoleSerializer,
        serializer: RoleSerializer
    end
  end
end
