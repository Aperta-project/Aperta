class FlowQuery
  attr_reader :user, :flow

  def initialize(user, flow)
    @user = user
    @flow = flow
  end

  def tasks
    return Task.none if flow.query.nil?

    scope = Task.all
    scope = by_journal(scope) unless user.site_admin?

    flow.query.keys.each do |query_scope|
      scope = send(query_scope, scope)
    end

    scope
  end

  def lite_papers
    Paper.joins(:tasks).
      includes(:paper_roles).
      where("tasks.id" => tasks.pluck(:id)).
      uniq
  end

  private

  def state_query(scope)
    scope.send(flow.state_query)
  end

  def role_query(scope)
    scope.for_role(flow.role_query)
  end

  def assigned_query(scope)
    flow.assigned? ? scope.assigned_to(user) : scope.unassigned
  end

  def type_query(scope)
    scope.where(type: flow.type_query)
  end

  def by_journal(scope)
    journals = flow.default? ? user.journals : [flow.journal]
    scope.on_journals(journals)
  end
end
