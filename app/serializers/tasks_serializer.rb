class TasksSerializer < ActiveModel::ArraySerializer
  include PolyArraySerializer

  self.each_serializer = TaskSerializer
end
