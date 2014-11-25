class FlowQuery
  attr_reader :user, :scope_to_journals

  def initialize(user, role_flow)
    @user = user
    @role_flow = role_flow
  end

  def tasks
    arr = role_flow.query
    scope = Tasks.includes(:paper)
    unless user.site_admin?
      if role_flow.default?
        scope = scope.on_journals(user.journals)
      else
        scope = scope.on_journals(*role_flow.journal)
      end
    end

    if arr.include?(:assigned)
      arr.delete(:assigned)
      scope = scope.assigned_to(user)
    end

    scope.call(arr.join("."))
  end

  def lite_papers
    @lite_papers ||= Paper.joins(:tasks).
      includes(:paper_roles).
      where("tasks.id" => tasks).
      uniq
  end

  private

  def paper_admin_tasks_for_user
    Task.admin.
      joins(paper: :assigned_users).
      merge(PaperRole.admins.for_user(user))
  end

  def attached_journal_ids
    @attached_journal_ids ||= user.roles.pluck(:journal_id).uniq
  end
end
