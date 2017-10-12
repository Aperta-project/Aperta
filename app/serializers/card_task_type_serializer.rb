class CardTaskTypeSerializer < ActiveModel::Serializer
  attributes :id,
             :display_name,
             :task_class
end
