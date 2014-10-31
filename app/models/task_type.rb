class TaskType
  cattr_accessor(:types) { HashWithIndifferentAccess.new }

  def self.register(task_klass, default_title, default_role)
    types[task_klass.name] = { default_title: default_title, default_role: default_role }
  end

  def self.constantize!(type)
    raise "#{type} is not a registered TaskType" unless types.keys.include?(type)
    type.constantize
  end
end
