class CardTaskTypeSerializer < AuthzSerializer
  attributes :id,
             :display_name,
             :task_class
end
