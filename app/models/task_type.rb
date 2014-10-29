class TaskType
  cattr_accessor(:types) { Hash.new }

  def self.register(task_klass, default_title, default_role)
    types[task_klass.name] = { default_title: default_title, default_role: default_role }
  end
end
