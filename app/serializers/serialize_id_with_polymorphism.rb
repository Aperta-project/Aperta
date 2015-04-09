module SerializeIdWithPolymorphism
  def self.call(item)
    task_type_parts = item.type.split '::'

    task_type = if task_type_parts.length == 1
                  item.type
                elsif task_type_parts[-1] =~ /\A.+Task\z/
                  task_type_parts[-1]
                else
                  raise "The task type: '#{item.type}' is not qualified."
                end

    { id: item.id, type: task_type }
  end
end
