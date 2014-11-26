module TaskFactory
  def self.build_task(task_klass, task_params)
    role = find_role(task_klass, task_params[:phase_id])
    task_klass.create!(task_params.merge(role: role))
  end

  def self.find_role(task_klass, phase_id)
    Phase.find(phase_id).journal.journal_task_types.find_by(kind: task_klass).role
  end
end
