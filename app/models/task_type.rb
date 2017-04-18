class TaskType
  cattr_accessor(:types) { HashWithIndifferentAccess.new }

  def self.register(task_klass, title)
    types[task_klass.name] = {
      default_title: title
    }
  end

  def self.deregister(task_klass)
    types.delete(task_klass.name)
  end

  def self.constantize!(type)
    raise "#{type} is not a registered TaskType" unless types.keys.include?(type)
    type.constantize
  end
end
