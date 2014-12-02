class FlowQuery
  attr_reader :user, :role_flow

  USER_FILTERS = [:assigned, :admin]

  def initialize(user, role_flow)
    @user = user
    @role_flow = role_flow
  end

  def tasks
    scope = Task.includes(:paper)

    unless user.site_admin?
      if role_flow.default?
        scope = scope.on_journals(user.journals)
      else
        scope = scope.on_journals([role_flow.journal])
      end
    end

    arr = role_flow.query
    scope = scope.assigned_to(user) if arr.include?(:assigned)
    scope = scope.admin_for_user(user) if arr.include?(:admin)

    arr.reject { |key| USER_FILTERS.include?(key) }.each do |s|
      scope = scope.send(s)
    end

    scope
  end

  def lite_papers
    @lite_papers ||= Paper.joins(:tasks).
      includes(:paper_roles).
      where("tasks.id" => tasks).
      uniq
  end

  private

  def attached_journal_ids
    @attached_journal_ids ||= user.roles.pluck(:journal_id).uniq
  end
end
