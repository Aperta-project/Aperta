module Tahi
  module AssignTeam
    class AssignTeamTaskSerializer < ::TaskSerializer
      has_many :assignments, embed: :ids,
                             include: true,
                             each_serializer: PaperRoleSerializer,
                             serializer: PaperRoleSerializer
    end
  end
end
