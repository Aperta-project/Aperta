class JournalAdminFlowSerializer < FlowSerializer
  def cached_tasks
    @cached_tasks ||= Task.joins(paper: :journal)
      .assigned_to(current_user).includes(:paper)
      .where(journals: {id: current_user.roles.pluck(:journal_id).uniq })
  end

  def paper_admin_tasks
    Task.joins(paper: [:assigned_users, :journal])
      .includes(:paper)
      .merge(PaperRole.admins.for_user(current_user))
      .where(type: "StandardTasks::PaperAdminTask")
      .where(journals: {id: current_user.roles.pluck(:journal_id).uniq })
  end

  def unassigned_tasks
    Task.joins(paper: :journal)
      .includes(:paper)
      .incomplete.unassigned
      .where(type: "StandardTasks::PaperAdminTask")
      .where(journals: {id: current_user.roles.pluck(:journal_id).uniq })
  end
end
