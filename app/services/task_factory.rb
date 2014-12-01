module TaskFactory
  def self.create(task_klass, task_params)
    build(task_klass, task_params).save!
  end

  def self.build(task_klass, task_params)
    role = find_role(task_klass, task_params[:phase_id])
    task_klass.new(task_params.merge(role: role))
  end

  def self.find_role(task_klass, phase_id)
    Phase.find(phase_id).journal.journal_task_types.find_by(kind: task_klass).role
  end
end
