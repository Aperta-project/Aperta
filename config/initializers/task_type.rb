class TaskType
  TYPES = Hash.new
  class << self
    def types
      TaskType::TYPES
    end
  end

  def self.register(task_klass, default_title, default_role)
    TYPES[task_klass.name] = { default_title: default_title, default_role: default_role, constantized_version: task_klass.name.constantize }
    # types[task_klass.name] = { default_title: default_title, default_role: default_role }
  end

  def self.constantize!(type)
    raise "#{type} is not a registered TaskType" unless types.keys.include?(type)
    type.constantize
  end

  def self.before_remove_const
    puts "removed tasktype constant"
  end
end
