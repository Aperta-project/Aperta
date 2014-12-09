class FlowSerializer < UserFlowSerializer
  attributes :role_id, :position, :query
  has_many :journal_task_types, embed: :ids, include: true

  delegate :journal_task_types, to: :journal

  private

  def journal
    object.journal
  end
end
