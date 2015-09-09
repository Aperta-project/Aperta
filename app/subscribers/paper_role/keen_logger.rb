class PaperRole::KeenLogger < KeenSubscriber

  def collection
    :papers
  end

  def payload
    role_kind = record.role
    roles_for_kind = record.paper.paper_roles.where(role: role_kind)

    {
      id: record.id,
      role: role_kind,
      journal_id: record.paper.journal.id,
      paper_id: record.paper.id,
      total_count_for_kind: roles_for_kind.count
    }
  end

end
