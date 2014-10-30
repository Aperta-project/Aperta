module TaskFactory
  def self.build_task(task_klass, task_params, user)
    role = find_role(task_klass, task_params[:phase_id])
    task_factories[task_klass.to_s].build(task_params.merge(role: role), user)
  end

  def self.task_factories
    HashWithIndifferentAccess.new({
      Task: AdHocTaskFactory,
      MessageTask: MessageTaskFactory
    })
  end

  def self.find_role(task_klass, phase_id)
    Phase.find(phase_id).journal.journal_task_types.find_by(kind: task_klass).role
  end
end
