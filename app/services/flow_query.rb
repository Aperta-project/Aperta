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

  def state(scope)
    scope.send(flow.query[:state])
  end

  def role(scope)
    scope.for_role(flow.query[:role])
  end

  def assigned(scope)
    flow.query[:assigned] ? scope.assigned_to(user) : scope.unassigned
  end

  def type(scope)
    scope.where(type: flow.query[:type])
  end

  def by_journal(scope)
    journals = flow.default? ? user.journals : [flow.journal]
    scope.on_journals(journals)
  end
end
