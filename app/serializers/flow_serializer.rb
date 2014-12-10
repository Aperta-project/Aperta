class FlowSerializer < UserFlowSerializer
  attributes :role_id, :position, :query, :task_roles
  has_many :journal_task_types, embed: :ids, include: true

  delegate :journal_task_types, to: :journal

  private

  def task_roles
    Task.unscoped.select(:role).distinct.pluck(:role)
  end

  def journal
    object.journal
  end
end
